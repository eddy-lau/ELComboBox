//
//  ComboBoxDataSource.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 22/1/14.
//
//

#import <Foundation/Foundation.h>

@class ELComboBox;
@protocol ELComboBoxDataSource <NSObject>

- (NSInteger) numberOfSectionsInComboBox:(ELComboBox *)comboBox;

- (NSInteger) comboBox:(ELComboBox *)comboBox numberOfOptionsInSection:(NSInteger)section;

- (NSString *) comboBox:(ELComboBox *)comboBox textForOptionAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *) comboBox:(ELComboBox *)comboBox keywordForOptionAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSString *) comboBox:(ELComboBox *)comboBox titleForHeaderInSection:(NSInteger)section;

@end
