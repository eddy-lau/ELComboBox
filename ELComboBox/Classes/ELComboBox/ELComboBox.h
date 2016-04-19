//
//  ComboBox.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 21/1/14.
//
//

#import <UIKit/UIKit.h>
#import "ELComboBoxDataSource.h"
#import "ELComboBoxDelegate.h"
#import "ELAutoCompleteTextField.h"

@interface ELComboBox : UIView

@property (nonatomic,readonly) ELAutoCompleteTextField      *textField;
@property (nonatomic,assign)   id<ELComboBoxDataSource>    dataSource;
@property (nonatomic,assign)   id<ELComboBoxDelegate>      delegate;
@property (nonatomic,copy)     NSArray                    *options;

@property (nonatomic,retain)   UIView                  *optionsViewHeader;
@property (nonatomic)          NSInteger                numberOfColumns;

@property (nonatomic)          NSTextAlignment          optionsViewTextAligment;
@property (nonatomic)          CGFloat                  optionsViewTextLeftMargin;
@property (nonatomic,retain)   UIFont                  *optionsViewSectionTitleFont;
@property (nonatomic,retain)   UIColor                 *optionsViewSectionTitleColor;
@property (nonatomic,retain)   UIColor                 *optionsViewSectionBackgroundColor;
@property (nonatomic)          CGFloat                  sectionHeaderTextLeftMargin;

- (void) reloadData;
- (NSArray *) indexPathsForFilteredOptions;
- (void) setNumberOfColumns:(NSInteger)numberOfColumns animated:(BOOL)animated;


- (void) setOptionsViewFont:(UIFont *)font        forState:(UIControlState)state;
- (void) setOptionsViewTextColor:(UIColor *)color forState:(UIControlState)state;
- (void) setOptionsViewBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (void) setOptionsViewSectionTitleFont:(UIFont *)font;

- (UIFont *) optionsViewFontForState:(UIControlState)state;


@end
