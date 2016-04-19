//
//  ELComboBoxLayout.m
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 19/2/14.
//
//

#import "ELComboBoxLayout.h"

NSString *ELComboBoxSupplementaryViewKindTableHeader = @"ELComboBoxSupplementaryViewKindTableHeader";

@implementation ELComboBoxLayout

- (void) dealloc {
    self.tableHeaderView = nil;
    [super dealloc];
}

- (void) prepareLayout {
    [super prepareLayout];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([ELComboBoxSupplementaryViewKindTableHeader isEqualToString:kind]) {
        
        UICollectionViewLayoutAttributes *attr =
        [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        attr.frame = CGRectMake(0, 0, self.collectionViewContentSize.width, self.tableHeaderView.frame.size.height);
        
        return attr;
        
    } else {
        return [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    }
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
    
    if (self.tableHeaderView) {
        
        for (UICollectionViewLayoutAttributes *attr in attrs) {
            CGRect f = attr.frame;
            f.origin.y += self.tableHeaderView.frame.size.height;
            attr.frame = f;
        }
        
        NSMutableArray *newAttrs = [NSMutableArray arrayWithArray:attrs];
        
        UICollectionViewLayoutAttributes *attr =
            [self layoutAttributesForSupplementaryViewOfKind:ELComboBoxSupplementaryViewKindTableHeader
                                                 atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        [newAttrs insertObject:attr atIndex:0];
        
        
        return newAttrs;
        
    } else {
        return attrs;
    }
}

- (CGSize) collectionViewContentSize {
    
    CGSize contentSize = [super collectionViewContentSize];
    
    if (self.tableHeaderView) {
        contentSize.height += self.tableHeaderView.frame.size.height;
    }
    
    return contentSize;
    
}

@end
