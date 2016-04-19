//
//  AutoCompleteTextFieldDataSource.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 22/1/14.
//
//

#import <Foundation/Foundation.h>

@protocol ELAutoCompleteTextFieldDataSource <NSObject>

@optional
- (NSString *)autoCompleteTextField:(ELAutoCompleteTextField *)textField completionTextForText:(NSString *)text;

@end
