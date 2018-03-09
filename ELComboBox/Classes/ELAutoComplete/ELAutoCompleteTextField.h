//
//  AutoCompleteTextField.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 8/1/14.
//
//

#import <UIKit/UIKit.h>
#import "ELAutoCompleteTextFieldDelegate.h"
#import "ELAutoCompleteTextFieldDataSource.h"


@interface ELAutoCompleteTextField : UIView

@property (nonatomic,assign) id<ELAutoCompleteTextFieldDelegate>   delegate;
@property (nonatomic,assign) id<ELAutoCompleteTextFieldDataSource> dataSource;

@property (nonatomic,copy)      NSString         *text;
@property (nonatomic,readonly)  NSString         *predictionText;
@property (nonatomic,copy)      NSString         *placeholder;
@property (nonatomic,retain)    UIFont           *font;
@property (nonatomic)           NSTextAlignment   textAlignment;
@property (nonatomic)           UIReturnKeyType   returnKeyType;
@property (nonatomic)           UIKeyboardType    keyboardType;
@property (nonatomic,retain)    UIView           *accessoryView;

@end
