//
//  ComboBoxDelegate.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 22/1/14.
//
//

#import <Foundation/Foundation.h>

@class ELComboBox;
@class ELAutoCompleteTextField;
@protocol ELComboBoxDelegate <NSObject>

@optional

- (UIView *) parentViewForOptionsViewInComboBox:(ELComboBox *)comboBox;
- (CGRect) optionsViewRectInComboBox:(ELComboBox *)comboBox;

- (BOOL) comboBoxShouldBeginEditing:(ELComboBox *)comboBox;
- (void) comboBoxDidBeginEditing:(ELComboBox *)comboBox;
- (void) comboBoxDidEndEditing:(ELComboBox *)comboBox;
- (void) comboBox:(ELComboBox *)comboBox didSelectOptionAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL) comboBoxShouldReturn:(ELComboBox *)comboBox;
- (void) comboBox:(ELComboBox *)comboBox textFieldDidChange:(ELAutoCompleteTextField *)textField;

@end
