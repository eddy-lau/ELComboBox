//
//  AutoCompleteTextFieldDelegate.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 22/1/14.
//
//

#import <Foundation/Foundation.h>

@class ELAutoCompleteTextField;
@protocol ELAutoCompleteTextFieldDelegate <NSObject>

@optional
- (BOOL) autoCompleteTextFieldShouldBeginEditing:(ELAutoCompleteTextField *)textField;
- (void) autoCompleteTextFieldDidBeginEditing:(ELAutoCompleteTextField *)textField;
- (void) autoCompleteTextFieldDidEndEditing:(ELAutoCompleteTextField *)textField;
- (void) autoCompleteTextFieldDidChange:(ELAutoCompleteTextField *)textField;
- (void) autoCompleteTextFieldDidAutoCompletion:(ELAutoCompleteTextField *)textField;
- (BOOL) autoCompleteTextFieldShouldReturn:(ELAutoCompleteTextField *)textField;

@end
