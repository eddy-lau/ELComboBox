//
//  ComboBox.m
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 21/1/14.
//
//

#import "ELComboBox.h"
#import "ELAutoCompleteTextField.h"
#import "ELComboBoxOptionCell.h"
#import "ELComboxSectionHeaderView.h"
#import "ELComboBoxLayout.h"
#import "ELComboBoxTableHeaderView.h"

#define kCollectionViewCellId @"kCollectionViewCellId"
#define kCollectionViewHeaderId @"kCollectionViewHeaderId"
#define kTableHeaderId @"kTableHeaderId"

@interface ComboBoxOption : NSObject

@property (nonatomic,readonly) NSIndexPath  *indexPath;
@property (nonatomic,readonly) NSString     *keyword;
@property (nonatomic,readonly) NSString     *text;

+ (ComboBoxOption *) optionWithKeyword:(NSString *)keyword text:(NSString *)text indexPath:(NSIndexPath *)indexPath;

@end

@implementation ComboBoxOption

- (id) initWithKeyword:(NSString *)keyword text:(NSString *)text indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (self) {
        _keyword = [keyword copy];
        _text = [text copy];
        _indexPath = [indexPath copy];
    }
    return self;
}

+ (ComboBoxOption *) optionWithKeyword:(NSString *)keyword text:(NSString *)text indexPath:(NSIndexPath *)indexPath {
    
    return [[[ComboBoxOption alloc] initWithKeyword:keyword text:text indexPath:indexPath] autorelease];
    
}

- (void) dealloc {
    [_indexPath release];
    [_keyword release];
    [_text release];
    [super dealloc];
}

@end

#pragma mark -

@interface ELComboBox ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    ELAutoCompleteTextFieldDataSource,
    ELAutoCompleteTextFieldDelegate
>

@property (nonatomic,retain,readwrite)  ELAutoCompleteTextField       *textField;
@property (nonatomic,retain)            UICollectionView            *optionsView;
@property (nonatomic,retain)            NSMutableArray              *filteredOptions;
@property (nonatomic,retain)            NSValue                     *keyboardFrame;
@property (nonatomic,retain)            NSMutableDictionary         *optionsViewFonts;
@property (nonatomic,retain)            NSMutableDictionary         *optionsViewTextColors;
@property (nonatomic,retain)            NSMutableDictionary         *optionsViewBackgroundColors;

@end

@implementation ELComboBox

@synthesize numberOfColumns          = _numberOfColumns;
@synthesize optionsViewHeader        = _optionsViewHeader;
@synthesize optionsViewTextAligment  = _optionsViewTextAligment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.filteredOptions = [NSMutableArray array];
        self.optionsViewFonts = [NSMutableDictionary dictionary];
        self.optionsViewTextColors = [NSMutableDictionary dictionary];
        self.optionsViewBackgroundColors = [NSMutableDictionary dictionary];
        _numberOfColumns = 1;
        
        [self setOptionsViewFont:[UIFont systemFontOfSize:18] forState:UIControlStateNormal];
        [self setOptionsViewBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self setOptionsViewBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1] forState:UIControlStateHighlighted];
        [self setOptionsViewSectionTitleBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0]];
        
        /*
         * AutoCompleteTextField
         */
        self.textField = [[[ELAutoCompleteTextField alloc] initWithFrame:self.bounds] autorelease];
        self.textField.delegate = self;
        self.textField.dataSource = self;
        [self addSubview:self.textField];
        
        /*
         * Filtered Result table view
         */
        ELComboBoxLayout *layout = [[[ELComboBoxLayout alloc] init] autorelease];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        layout.minimumInteritemSpacing = 0.0;
        layout.minimumLineSpacing = 0.0;
        layout.itemSize = [self optionsViewItemSize];
        
        self.optionsView = [[[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout] autorelease];
        self.optionsView.backgroundColor = [UIColor whiteColor];
        self.optionsView.dataSource = self;
        self.optionsView.delegate = self;
        [self.optionsView registerClass:[ELComboBoxOptionCell class] forCellWithReuseIdentifier:kCollectionViewCellId];
        [self.optionsView registerClass:[ELComboxSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionViewHeaderId];
        [self.optionsView registerClass:[ELComboBoxTableHeaderView class] forSupplementaryViewOfKind:ELComboBoxSupplementaryViewKindTableHeader withReuseIdentifier:kTableHeaderId];
        
        /*
         * Keyboard callbacks
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShowNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShowNotification:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHideNotification:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
    }
    return self;
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.delegate = nil;
    self.dataSource = nil;
    self.optionsViewSectionTitleColor = nil;
    self.optionsViewSectionTitleFont = nil;
    self.optionsViewBackgroundColors = nil;
    self.optionsViewTextColors = nil;
    self.optionsViewFonts = nil;
    self.options = nil;
    self.keyboardFrame = nil;
    self.filteredOptions = nil;
    self.textField = nil;
    self.optionsView = nil;
    [_optionsViewHeader release];
    [super dealloc];
}

#pragma mark layout

- (void) layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = self.bounds;
    
    if (!CGRectEqualToRect(self.optionsView.frame, [self tableViewRect])) {
        self.optionsView.frame = [self tableViewRect];
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.optionsView.contentInset, [self tableViewContentInset])) {
        self.optionsView.contentInset = [self tableViewContentInset];
    }

    if (!UIEdgeInsetsEqualToEdgeInsets(self.optionsView.scrollIndicatorInsets, [self tableViewContentInset])) {
        self.optionsView.scrollIndicatorInsets = [self tableViewContentInset];
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.optionsView.collectionViewLayout;
    flowLayout.itemSize = [self optionsViewItemSize];
    
    
}

- (CGRect) tableViewRect {
    
    if ([self.delegate respondsToSelector:@selector(optionsViewRectInComboBox:)]) {
        
        return [self.delegate optionsViewRectInComboBox:self];
        
    } else {
        
        CGFloat x,y,w,h;
        w = self.bounds.size.width;
        h = [self parentView].bounds.size.height - CGRectGetMaxY(self.frame);

        y = CGRectGetMaxY(self.frame);
        x = CGRectGetMinX(self.frame);
        CGPoint origin = [[self parentView] convertPoint:CGPointMake(x, y) fromView:self.superview];
        return CGRectMake(origin.x, origin.y, w, h);
    }
}

- (CGSize) optionsViewItemSize {
    
    CGFloat w,h;
    w = floorf([self tableViewRect].size.width / self.numberOfColumns);
    h = 43;
    return CGSizeMake(w, h);
    
}

- (UIEdgeInsets) tableViewContentInset {
    
    CGFloat top,left,right,bottom;
    top = 0;
    left = 0;
    right = 0;
    bottom = 0;

    if (self.keyboardFrame && self.optionsView.superview) {
        CGRect keyboardFrame =  [self.optionsView.superview convertRect:[self.keyboardFrame CGRectValue] fromView:nil];
        CGRect tableViewWinFrame = [self.optionsView.superview convertRect:self.optionsView.bounds fromView:self.optionsView];
        
        if (CGRectGetMinY(keyboardFrame) < CGRectGetMaxY(tableViewWinFrame)) {
            bottom = CGRectGetMaxY(tableViewWinFrame) - CGRectGetMinY(keyboardFrame);
        }
    }
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (UIView *) parentView {
    
    UIView *view = nil;
    if ([self.delegate respondsToSelector:@selector(parentViewForOptionsViewInComboBox:)]) {
        view = [self.delegate parentViewForOptionsViewInComboBox:self];
    }
    
    if (view == nil) {
        view = self.superview;
    }
    
    return view;
    
}

- (ComboBoxOption *) filteredOptionAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *options = self.filteredOptions[indexPath.section];
    return options[indexPath.row];
}

#pragma mark AutoCompleteTextFieldDelegate

- (BOOL)autoCompleteTextFieldShouldBeginEditing:(ELAutoCompleteTextField *)textField {
    
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(comboBoxShouldBeginEditing:)]) {
        should = [self.delegate comboBoxShouldBeginEditing:self];
    }
    return should;
}

- (void)autoCompleteTextFieldDidBeginEditing:(ELAutoCompleteTextField *)textField {
    
    [self reloadData];
    self.optionsView.alpha = 0.0;
    [[self parentView] addSubview:self.optionsView];
    
    self.optionsView.frame = [self tableViewRect];
    self.optionsView.contentInset = [self tableViewContentInset];
    self.optionsView.scrollIndicatorInsets = [self tableViewContentInset];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.optionsView.alpha = 1.0;
    }];
    
    if ([self.delegate respondsToSelector:@selector(comboBoxDidBeginEditing:)]) {
        [self.delegate comboBoxDidBeginEditing:self];
    }
}

- (void) autoCompleteTextFieldDidChange:(ELAutoCompleteTextField *)textField {

    [self reloadData];
}

- (void)autoCompleteTextFieldDidEndEditing:(ELAutoCompleteTextField *)textField {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.optionsView.alpha = 0.0;
    } completion:^(BOOL completed){
        [self.optionsView removeFromSuperview];
    }];
    
    if ([self.delegate respondsToSelector:@selector(comboBoxDidEndEditing:)]) {
        [self.delegate comboBoxDidEndEditing:self];
    }
    
    /*
    ComboBoxOption *selectedOption = nil;
    for (NSArray *section in self.filteredOptions) {
        for (ComboBoxOption *option in section) {
            if ([textField.text isEqualToString:option.keyword]) {
                selectedOption = option;
                break;
            }
        }
    }
    
    if (selectedOption) {
        if ([self.delegate respondsToSelector:@selector(comboBox:didSelectOptionAtIndexPath:)]) {
            [self.delegate comboBox:self didSelectOptionAtIndexPath:selectedOption.indexPath];
        }
    }
     */

}

- (BOOL)autoCompleteTextFieldShouldReturn:(ELAutoCompleteTextField *)textField {
    
    BOOL defaultBehavior = YES;
    if ([self.delegate respondsToSelector:@selector(comboBoxShouldReturn:)]) {
        defaultBehavior = [self.delegate comboBoxShouldReturn:self];
    }

    if (defaultBehavior) {
        
        ComboBoxOption *option = nil;
        for (NSArray *options in self.filteredOptions) {
            
            if (options.count > 0) {
                option = options[0];
                break;
            }
            
        }
        
        if (option) {

            self.textField.text = option.keyword;
            
            if ([self.delegate respondsToSelector:@selector(comboBox:didSelectOptionAtIndexPath:)]) {
                [self.delegate comboBox:self didSelectOptionAtIndexPath:option.indexPath];
            }
            
            return NO;
        } else {
            return YES;
        }
        
    } else {
        return NO;
    }
    
}

#pragma mark AutoCompleteTextFieldDataSource

- (NSString *)autoCompleteTextField:(ELAutoCompleteTextField *)textField completionTextForText:(NSString *)text {

    for (NSArray *options in self.filteredOptions) {
    
        if (options.count > 0) {
            ComboBoxOption *option = options[0];
            return option.keyword;
        }
    
    }
    return nil;

}

#pragma mark Keyboard notifications

- (void) keyboardWillShowNotification:(NSNotification *)notification {
    
    self.keyboardFrame = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    [self setNeedsLayout];
    
}

- (void) keyboardDidShowNotification:(NSNotification *)notification {
    
}

- (void) keyboardDidHideNotification:(NSNotification *)notification {
    
    self.keyboardFrame = nil;
    [self setNeedsLayout];
}

#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filteredOptions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *options = self.filteredOptions[section];
    return options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"ComboBoxListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    
    cell.textLabel.text = [self filteredOptionAtIndexPath:indexPath].text;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *options = self.filteredOptions[section];
    if (options.count > 0 && [self.dataSource respondsToSelector:@selector(comboBox:titleForHeaderInSection:)]) {
        return [self.dataSource comboBox:self titleForHeaderInSection:section];
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ComboBoxOption *option = [self filteredOptionAtIndexPath:indexPath];
    self.textField.text = option.keyword;
    
    if ([self.delegate respondsToSelector:@selector(comboBox:didSelectOptionAtIndexPath:)]) {
        [self.delegate comboBox:self didSelectOptionAtIndexPath:option.indexPath];
    }
    
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.filteredOptions.count;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *options = self.filteredOptions[section];
    return options.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *options = self.filteredOptions[indexPath.section];
    ComboBoxOption *option = options[indexPath.row];
    
    ELComboBoxOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellId forIndexPath:indexPath];
    cell.titleLabel.font = self.optionsViewFonts[@(UIControlStateNormal)];
    cell.titleLabel.text = option.text;
    cell.titleLabel.textAlignment = self.optionsViewTextAligment;
    cell.titleLabel.textColor = self.optionsViewTextColors[@(UIControlStateNormal)];
    cell.titleLeftMargin = self.optionsViewTextLeftMargin;
    
    [cell setTextColor:self.optionsViewTextColors[@(UIControlStateNormal)] forState:UIControlStateNormal];
    [cell setTextColor:self.optionsViewTextColors[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
    [cell setBackgroundColor:self.optionsViewBackgroundColors[@(UIControlStateNormal)] forState:UIControlStateNormal];
    [cell setBackgroundColor:self.optionsViewBackgroundColors[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        ELComboxSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionViewHeaderId forIndexPath:indexPath];
        headerView.titleLabel.backgroundColor = self.optionsViewSectionBackgroundColor;
        NSArray *options = self.filteredOptions[indexPath.section];
        if (options.count > 0 && [self.dataSource respondsToSelector:@selector(comboBox:titleForHeaderInSection:)]) {
            NSString *title = [self.dataSource comboBox:self titleForHeaderInSection:indexPath.section];
            headerView.titleLabel.text = title;
            headerView.titleLeftMargin = self.sectionHeaderTextLeftMargin;
            headerView.titleLabel.textColor = self.optionsViewSectionTitleColor;
            headerView.titleLabel.font = self.optionsViewSectionTitleFont;
        } else {
            headerView.titleLabel.text = nil;
        }
        return headerView;
        
    } else if ([kind isEqualToString:ELComboBoxSupplementaryViewKindTableHeader]) {
        
        ELComboBoxTableHeaderView *tableHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kTableHeaderId forIndexPath:indexPath];
        [tableHeaderView addSubview:self.optionsViewHeader];
        return tableHeaderView;
        
    } else {
        
        return nil;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ComboBoxOption *option = [self filteredOptionAtIndexPath:indexPath];
    self.textField.text = option.keyword;
    
    if ([self.delegate respondsToSelector:@selector(comboBox:didSelectOptionAtIndexPath:)]) {
        [self.delegate comboBox:self didSelectOptionAtIndexPath:option.indexPath];
    }
    
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog (@"didHighlightItemAtIndexPath");
    
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog (@"didUnhighlightItemAtIndexPath");
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    NSString *headerTitle = nil;
    NSArray *options = self.filteredOptions[section];
    if (options.count > 0 && [self.dataSource respondsToSelector:@selector(comboBox:titleForHeaderInSection:)]) {
        headerTitle = [self.dataSource comboBox:self titleForHeaderInSection:section];
    }
    
    if (headerTitle) {
        
        CGFloat w = [self tableViewRect].size.width;
        CGFloat h = 30;
        
        if (self.optionsViewSectionTitleFont) {
            
            //h = [headerTitle sizeWithFont:self.optionsViewSectionTitleFont].height + 10;
            NSDictionary *attr = self.optionsViewSectionTitleFont ? @{ NSFontAttributeName : self.optionsViewSectionTitleFont} : nil;
            h = [headerTitle sizeWithAttributes:attr].height + 10;
        }
        
        return CGSizeMake(w, h);
        
    } else {
        
        return CGSizeMake(0, 0);
    }
}

#pragma mark public methods

- (void) reloadData {
    
    NSString *filterText = self.textField.text;
    if (filterText == nil) {
        filterText = @"";
    }
    
    [self.filteredOptions removeAllObjects];
    
    if (self.dataSource) {
        
        NSInteger sectionCount = [self.dataSource numberOfSectionsInComboBox:self];
        NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
        for (NSInteger section = 0; section < sectionCount; section++) {
            
            NSInteger rowCount = [self.dataSource comboBox:self numberOfOptionsInSection:section];
            NSMutableArray *options = [NSMutableArray arrayWithCapacity:rowCount];
            
            for (NSInteger row = 0; row < rowCount; row++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                NSString *keyword = [self.dataSource comboBox:self keywordForOptionAtIndexPath:indexPath];
                NSString *text = [self.dataSource comboBox:self textForOptionAtIndexPath:indexPath];
                
                NSRange subStringRange = [keyword rangeOfString:filterText options:NSCaseInsensitiveSearch];
                
                if (filterText.length == 0 || subStringRange.location != NSNotFound) {
                    ComboBoxOption *option = [ComboBoxOption optionWithKeyword:keyword text:text indexPath:indexPath];
                    [options addObject:option];
                }
            }
            
            [sections addObject:options];
        }
        
        [self.filteredOptions setArray:sections];
        
    } else if (self.options) {
        
        NSMutableArray *options = [NSMutableArray arrayWithCapacity:self.options.count];
        for (int i = 0; i<self.options.count; i++) {
            
            NSString *text = self.options[i];
            NSRange subStringRange = [text rangeOfString:filterText options:NSCaseInsensitiveSearch];
            
            if (filterText.length == 0 || subStringRange.location != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                ComboBoxOption *option = [ComboBoxOption optionWithKeyword:text text:text indexPath:indexPath];
                [options addObject:option];
            }
        }
        
        [self.filteredOptions addObject:options];
    }

    //[self.optionsView performSelector:@selector(reloadData)];
    [self.optionsView reloadData];
}

- (NSArray *) indexPathsForFilteredOptions {
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSArray *section in self.filteredOptions) {
        for (ComboBoxOption *option in section) {
            [indexPaths addObject:option.indexPath];
        }
    }
    return indexPaths;
}

- (void) setNumberOfColumns:(NSInteger)numberOfColumns {
    [self setNumberOfColumns:numberOfColumns animated:NO];
}

- (void) setNumberOfColumns:(NSInteger)numberOfColumns animated:(BOOL)animated {
    
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
        
        ELComboBoxLayout *layout = (ELComboBoxLayout *)self.optionsView.collectionViewLayout;
        
        if (layout == nil) {
            layout = [[[ELComboBoxLayout alloc] init] autorelease];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            layout.tableHeaderView = self.optionsViewHeader;
            layout.minimumInteritemSpacing = 0.0;
            layout.minimumLineSpacing = 0.0;
            layout.itemSize = [self optionsViewItemSize];
            [self.optionsView setCollectionViewLayout:layout animated:animated];
        } else {
            layout.itemSize = [self optionsViewItemSize];
        }
        
        if (layout.itemSize.width > 0 && layout.itemSize.height > 0) {
            
            CGRect bounds = self.optionsView.bounds;
            bounds.origin.y = 0;
//            [self.optionsView scrollRectToVisible:bounds animated:animated];
            self.optionsView.bounds = bounds;
            
//            [self.optionsView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
        }
        
        [self reloadData];
    }
}


- (void) setOptionsViewHeader:(UIView *)optionsViewHeader {
    if (_optionsViewHeader != optionsViewHeader) {
        [_optionsViewHeader release];
        _optionsViewHeader = [optionsViewHeader retain];
    }
}

- (void) setOptionsViewTextAligment:(NSTextAlignment)textAligment {
    if (_optionsViewTextAligment != textAligment) {
        _optionsViewTextAligment = textAligment;
        [self reloadData];
    }
}

- (void) setOptionsViewFont:(UIFont *)font forState:(UIControlState)state {
    
    self.optionsViewFonts[@(state)] = font;
    [self reloadData];
    
}

- (UIFont *) optionsViewFontForState:(UIControlState)state {
    return self.optionsViewFonts[@(state)];
}

- (void) setOptionsViewTextColor:(UIColor *)color forState:(UIControlState)state {
    
    self.optionsViewTextColors[@(state)] = color;
    [self reloadData];
    
}

- (void) setOptionsViewBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    
    self.optionsViewBackgroundColors[@(state)] = backgroundColor;
    [self reloadData];
    
}

- (void) setOptionsViewSectionTitleFont:(UIFont *)font {
    
    if (_optionsViewSectionTitleFont != font) {
        [_optionsViewSectionTitleFont release];
        _optionsViewSectionTitleFont = [font retain];
        [self reloadData];
    }
}

- (void) setOptionsViewSectionTitleBackgroundColor:(UIColor *)backgroundColor {
    
    if (_optionsViewSectionBackgroundColor != backgroundColor) {
        [_optionsViewSectionBackgroundColor release];
        _optionsViewSectionBackgroundColor = [backgroundColor retain];
        [self reloadData];
    }
    
}

- (void) setOptionsViewSectionTitleColor:(UIColor *)color {
    if (_optionsViewSectionTitleColor != color) {
        _optionsViewSectionTitleColor = [color retain];
        [self reloadData];
    }
}

- (void) setOptionsViewTextLeftMargin:(CGFloat)optionsViewTextLeftMargin {
    
    if (_optionsViewTextLeftMargin != optionsViewTextLeftMargin) {
        _optionsViewTextLeftMargin = optionsViewTextLeftMargin;
        [self reloadData];
    }
}

- (void) setSectionHeaderTextLeftMargin:(CGFloat)sectionHeaderTextLeftMargin {
    
    if (_sectionHeaderTextLeftMargin != sectionHeaderTextLeftMargin) {
        _sectionHeaderTextLeftMargin = sectionHeaderTextLeftMargin;
        [self reloadData];
    }
}

@end
