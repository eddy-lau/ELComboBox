//
//  AutoCompleteTextField.m
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 8/1/14.
//
//

#import "ELAutoCompleteTextField.h"
#import "ELTextField.h"


#ifdef __IPHONE_7_0
#define IS_BELOW_IOS7 ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending)
#else
#define IS_BELOW_IOS7 1
#endif



#define kDefaultTextHighlightColor ([UIColor colorWithRed:0.0 green:0.33 blue:0.63 alpha:0.2])

@interface ELAutoCompleteTextField ()
<
    UIGestureRecognizerDelegate,
    ELTextFieldDelegate
>
{
    NSString *_placeholder;
}

@property (nonatomic,retain) ELTextField             *textField;
@property (nonatomic,retain) UITapGestureRecognizer  *tapGesture;
@property (nonatomic,retain) UILabel                 *predictionLabel;
@property (nonatomic,retain) NSTimer                 *predictTimer;

@end

@implementation ELAutoCompleteTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.textField = [[[ELTextField alloc] initWithFrame:self.bounds] autorelease];
        self.textField.delegate = self;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:self.textField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidBeginEditingNotification:)
                                                     name:UITextFieldTextDidBeginEditingNotification
                                                   object:self.textField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChangeNotification:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:self.textField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidEndEditingNotification:)
                                                     name:UITextFieldTextDidEndEditingNotification
                                                   object:self.textField];
        
        self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTextField:)] autorelease];
        self.tapGesture.delegate = self;
        [self.textField addGestureRecognizer:self.tapGesture];
        
        self.predictionLabel = [[[UILabel alloc] initWithFrame:CGRectNull] autorelease];
        if (IS_BELOW_IOS7) {
            self.predictionLabel.backgroundColor = kDefaultTextHighlightColor;
        } else {
            self.predictionLabel.backgroundColor = [self.textField.tintColor colorWithAlphaComponent:0.2];
        }
        
        [self addSubview:self.predictionLabel];
        
        
        

    }
    return self;
}

- (void) dealloc {

    [self.predictTimer invalidate];
    self.predictTimer = nil;
    
    [_placeholder release];
    self.predictionLabel = nil;
    self.textField = nil;
    self.tapGesture = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark layout

- (void) layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = self.bounds;
    self.predictionLabel.frame = [self predictionLabelRect];
}

- (CGRect) predictionLabelRect {
    
    CGRect textFieldRect = [self.textField textRectForBounds:self.textField.bounds];
    NSDictionary *attr = self.predictionLabel.font ? @{ NSFontAttributeName : self.predictionLabel.font } : nil;
    CGSize predictionTextSize = [self.predictionLabel.text sizeWithAttributes:attr];
    
    CGFloat x = CGRectGetMinX([self.textField caretRectForPosition:[self.textField endOfDocument]]);
    CGFloat y = CGRectGetMinY(textFieldRect);
    CGFloat w = predictionTextSize.width;
    CGFloat h = CGRectGetHeight(textFieldRect);
    
    return [self convertRect:CGRectMake(x, y, w, h) fromView:self.textField];
}

#pragma mark private methods

- (void) didTapTextField:(id)sender {
}

- (void) setPredictionText:(NSString *)predictionText {
    
    if (predictionText.length > 0) {
        
        self.predictionLabel.alpha = 1.0;
        self.predictionLabel.text = predictionText;
        [self setNeedsLayout];
        self.textField.placeholder = nil;
        self.textField.hidesCaret = YES;
        
    } else {
        
        self.predictionLabel.alpha = 0.0;
        self.predictionLabel.text = nil;
        [self.textField sizeToFit];
        [self setNeedsLayout];
        if (_placeholder.length > 0) {
            self.textField.placeholder = _placeholder;
        }
        self.textField.hidesCaret = NO;
        
    }
    
}

- (void) performPrediction {
    
    
    UITextRange *markedTextRange = [self.textField markedTextRange];
    BOOL hasMarkText = markedTextRange && !markedTextRange.empty;
    
    if (!hasMarkText && [self.dataSource respondsToSelector:@selector(autoCompleteTextField:completionTextForText:)]) {
        
        NSString *text = self.textField.text;
        NSString *predictionText = [self.dataSource autoCompleteTextField:self completionTextForText:text];
        if (predictionText.length > 0) {
            
            NSRange range = [predictionText rangeOfString:text];
            if (range.location == 0) {
                predictionText = [predictionText substringFromIndex:text.length];
            } else {
                predictionText = nil;
            }
            
        }
        [self setPredictionText:predictionText];
        
    }
    
    self.predictTimer = nil;
}

- (void) schedulePrediction {
    
    [self.predictTimer invalidate];
    self.predictTimer = nil;
    self.predictTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(performPrediction) userInfo:nil repeats:NO];
    
}

#pragma mark Notifications

- (void) textFieldDidBeginEditingNotification:(NSNotification *)notification {
}

- (void) textFieldDidChangeNotification:(NSNotification *)notification {

    [self setPredictionText:nil];
    if (self.textField.text.length > 0) {
        [self schedulePrediction];
    } else {
        [self.predictTimer invalidate];
        self.predictTimer = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(autoCompleteTextFieldDidChange:)]) {
        [self.delegate autoCompleteTextFieldDidChange:self];
    }
    
}

- (void) textFieldDidEndEditingNotification:(NSNotification *)notification {
}

#pragma mark ACTextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    NSString *text = [[self.textField.text copy] autorelease];
    if (text.length > 0) {
        self.textField.text = nil;
        [self setPredictionText:text];
    }
    
    if ([self.delegate respondsToSelector:@selector(autoCompleteTextFieldDidBeginEditing:)]) {
        [self.delegate autoCompleteTextFieldDidBeginEditing:self];
    }
    
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(autoCompleteTextFieldShouldBeginEditing:)]) {
        return [self.delegate autoCompleteTextFieldShouldBeginEditing:self];
    } else {
        return YES;
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSString *predictionText = [[[self predictionText] copy] autorelease];
    
    if (predictionText.length > 0) {
        
        if (self.text.length > 0 && [self.dataSource respondsToSelector:@selector(autoCompleteTextField:completionTextForText:)]) {
            NSString *fullText = [self.dataSource autoCompleteTextField:self completionTextForText:self.textField.text];
            self.textField.text = fullText;
        } else {
            self.textField.text = [NSString stringWithFormat:@"%@%@", self.textField.text, predictionText];
        }
        
    }
    
    [self setPredictionText:nil];
    [self.predictTimer invalidate];
    self.predictTimer = nil;
    
    if ([self.delegate respondsToSelector:@selector(autoCompleteTextFieldDidEndEditing:)]) {
        [self.delegate autoCompleteTextFieldDidEndEditing:self];
    }
    
}

- (void) textFieldWillDeleteBackward:(ELTextField *)textField {
    
}

- (BOOL) textFieldShouldDeleteBackward:(ELTextField *)textField {
    
    if ([self predictionText].length > 0) {
        [self setPredictionText:nil];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(autoCompleteTextFieldShouldReturn:)]) {
        return [self.delegate autoCompleteTextFieldShouldReturn:self];
    } else {
        return YES;
    }
}

#pragma mark UIGestureRecogizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark public methods

- (BOOL) becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL) resignFirstResponder {
    return [self.textField resignFirstResponder];
}

- (BOOL) isFirstResponder {
    return [self.textField isFirstResponder];
}

- (BOOL) canBecomeFirstResponder {
    return [self.textField canBecomeFirstResponder];
}

- (BOOL) canResignFirstResponder {
    return [self.textField canResignFirstResponder];
}

- (void) setText:(NSString *)text {
    [self setPredictionText:nil];
    self.textField.text = text;
}

- (NSString *) text {
    return self.textField.text;
}

- (void) setPlaceholder:(NSString *)placeholder {
    [_placeholder release];
    _placeholder = [placeholder copy];
    if ([self predictionText].length == 0) {
        self.textField.placeholder = _placeholder;
    }
}

- (NSString *) placeholder {
    return _placeholder;
}

- (void) setFont:(UIFont *)font {
    self.textField.font = font;
    self.predictionLabel.font = font;
}

- (UIFont *) font {
    return self.textField.font;
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment {
    self.textField.textAlignment = textAlignment;
}

- (NSTextAlignment) textAlignment {
    return self.textField.textAlignment;
}

- (void) setAccessoryView:(UIView *)inputAccessoryView {
    self.textField.inputAccessoryView = inputAccessoryView;
}

- (UIView *) accessoryView {
    return self.textField.inputAccessoryView;
}

- (void) setReturnKeyType:(UIReturnKeyType)returnKeyType {
    self.textField.returnKeyType = returnKeyType;
}

- (UIReturnKeyType) returnKeyType {
    return self.textField.returnKeyType;
}

- (void) setKeyboardType:(UIKeyboardType)keyboradType {
    
    if (!IS_BELOW_IOS7) {
        
        /* Fixed the iOS 7 marked text problem */
        
        if (keyboradType == UIKeyboardTypeNumberPad) {
            self.textField.allowsMarkedText = NO;
        } else {
            self.textField.allowsMarkedText = YES;
        }
    }
    
    self.textField.keyboardType = keyboradType;
}

- (UIKeyboardType) keyboardType {
    return self.textField.keyboardType;
}

- (NSString *) predictionText {
    return self.predictionLabel.text;
}

@end
