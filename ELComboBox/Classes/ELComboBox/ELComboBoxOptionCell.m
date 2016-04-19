//
//  ELComboBoxOptionCell.m
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 19/2/14.
//
//

#import "ELComboBoxOptionCell.h"

@interface ELCellBorderView : UIView

@end

@implementation ELCellBorderView

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMaxX(self.bounds), 0);
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    CGContextAddLineToPoint(context, CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor);
    CGContextStrokePath(context);
    
}

@end



@interface ELComboBoxOptionCell ()

@property (nonatomic,assign,readwrite) UILabel *titleLabel;
@property (nonatomic,assign)           ELCellBorderView *borderView;
@property (nonatomic,retain)           NSMutableDictionary *textColors;
@property (nonatomic,retain)           NSMutableDictionary *backgroundColors;

@end

@implementation ELComboBoxOptionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textColors = [NSMutableDictionary dictionary];
        self.backgroundColors = [NSMutableDictionary dictionary];
        
        self.borderView = [[[ELCellBorderView alloc] initWithFrame:self.bounds] autorelease];
        self.borderView.contentMode = UIViewContentModeRedraw;
        self.borderView.backgroundColor = [UIColor clearColor];
        self.borderView.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
        self.borderView.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.borderView];
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:[self titleLabelFrame]] autorelease];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        self.titleLabel.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
        self.titleLabel.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void) dealloc {
    self.textColors = nil;
    self.backgroundColors = nil;
    self.borderView = nil;
    self.titleLabel = nil;
    [super dealloc];
}

- (CGRect) titleLabelFrame {
    CGRect titleLabelFrame = self.contentView.bounds;
    titleLabelFrame.origin.x = self.titleLeftMargin;
    titleLabelFrame.size.width -= self.titleLeftMargin;
    return titleLabelFrame;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = [self titleLabelFrame];
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        
        UIColor *backgroundColor = self.backgroundColors[@(UIControlStateHighlighted)];
        if (backgroundColor) {
            self.titleLabel.backgroundColor = backgroundColor;
        }
        
        UIColor *textColor = self.textColors[@(UIControlStateHighlighted)];
        if (textColor) {
            self.titleLabel.textColor = textColor;
        }
        
    } else {
        
        UIColor *backgroundColor = self.backgroundColors[@(UIControlStateNormal)];
        if (backgroundColor) {
            self.titleLabel.backgroundColor = backgroundColor;
        }
        
        UIColor *textColor = self.textColors[@(UIControlStateNormal)];
        if (textColor) {
            self.titleLabel.textColor = textColor;
        }
    }
    
}

- (void) setTextColor:(UIColor *)color forState:(UIControlState)state {
    
    if (color) {
        self.textColors[@(state)] = color;
    } else {
        [self.textColors removeObjectForKey:@(state)];
    }
}

- (void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    
    if (backgroundColor) {
        self.backgroundColors[@(state)] = backgroundColor;
    } else {
        [self.backgroundColors removeObjectForKey:@(state)];
    }
}

@end
