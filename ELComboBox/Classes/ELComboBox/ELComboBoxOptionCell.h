//
//  ELComboBoxOptionCell.h
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 19/2/14.
//
//

#import <UIKit/UIKit.h>

@interface ELComboBoxOptionCell : UICollectionViewCell

@property (nonatomic,readonly) UILabel *titleLabel;
@property (nonatomic)          CGFloat  titleLeftMargin;

- (void) setTextColor:(UIColor *)color forState:(UIControlState)state;
- (void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end
