//
//  ACTextField.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 23/1/14.
//
//

#import <UIKit/UIKit.h>
#import "ELTextFieldDelegate.h"

@interface ELTextField : UITextField

@property (nonatomic) BOOL hidesCaret;
@property (nonatomic) BOOL allowsMarkedText;

@end
