//
//  ACTextField.m
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 23/1/14.
//
//

#import "ELTextField.h"

@interface ELTextField ()
{
    BOOL _hidesCaret;
}

@end

@implementation ELTextField

@synthesize hidesCaret = _hidesCaret;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hidesCaret = NO;
        self.allowsMarkedText = YES;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

- (id<ELTextFieldDelegate>) acTextFieldDelegate {
    
    if ([self.delegate conformsToProtocol:@protocol(ELTextFieldDelegate)]) {
        return (id<ELTextFieldDelegate>)self.delegate;
    } else {
        return nil;
    }
    
}

- (void) deleteBackward {
    
    BOOL should = YES;
    
    if ([self.acTextFieldDelegate respondsToSelector:@selector(textFieldShouldDeleteBackward:)]) {
        should = [self.acTextFieldDelegate textFieldShouldDeleteBackward:self];
    }
    
    if (should) {
        
        if ([self.acTextFieldDelegate respondsToSelector:@selector(textFieldWillDeleteBackward:)]) {
            [self.acTextFieldDelegate textFieldWillDeleteBackward:self];
        }
        
        [super deleteBackward];
    }
}

- (CGRect) caretRectForPosition:(UITextPosition *)position {
    CGRect rect = [super caretRectForPosition:position];
    if (_hidesCaret) {
        rect.size.width = 0.0;
    }
    return rect;
}

- (void) setHidesCaret:(BOOL)caretHidden {
    
    if (_hidesCaret != caretHidden) {
        _hidesCaret = caretHidden;
    
        UITextRange *caretPosition = self.selectedTextRange;
        
        UITextRange *textRange = [self textRangeFromPosition:[self beginningOfDocument] toPosition:[self beginningOfDocument]];
        [self setSelectedTextRange:textRange];
        
        self.selectedTextRange = caretPosition;
        
    }
    
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {
    if (self.allowsMarkedText) {
        [super setMarkedText:markedText selectedRange:selectedRange];
    }
}

@end
