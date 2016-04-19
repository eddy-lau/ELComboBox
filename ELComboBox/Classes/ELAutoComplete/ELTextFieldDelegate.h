//
//  ACTextFieldDelegate.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 23/1/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ELTextField;
@protocol ELTextFieldDelegate <UITextFieldDelegate>

@optional
- (BOOL) textFieldShouldDeleteBackward:(ELTextField *)textField;
- (void) textFieldWillDeleteBackward:(ELTextField *)textField;

@end
