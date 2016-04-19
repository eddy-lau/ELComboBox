//
//  ELComboxHeaderView.m
//  TouchBibles
//
//  Created by Eddie Hiu-Fung Lau on 19/2/14.
//
//

#import "ELComboxSectionHeaderView.h"

@interface ELSectionHeaderBorderView : UIView

@end

@implementation ELSectionHeaderBorderView

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    CGContextAddLineToPoint(context, CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor);
    CGContextStrokePath(context);
    
}

@end



@interface ELComboxSectionHeaderView ()

@property (nonatomic,assign,readwrite) UILabel *titleLabel;

@end

@implementation ELComboxSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:[self titleLabelFrame]] autorelease];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
        self.titleLabel.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
        self.titleLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
        self.titleLabel.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
        [self addSubview:self.titleLabel];
        
        ELSectionHeaderBorderView *borderView = [[[ELSectionHeaderBorderView alloc] initWithFrame:self.bounds] autorelease];
        borderView.backgroundColor = [UIColor clearColor];
        borderView.contentMode = UIViewContentModeRedraw;
        borderView.autoresizesSubviews |= UIViewAutoresizingFlexibleHeight;
        borderView.autoresizesSubviews |= UIViewAutoresizingFlexibleWidth;
        [self addSubview:borderView];
        
    }
    return self;
}

- (void) dealloc {
    self.titleLabel = nil;
    [super dealloc];
}

- (CGRect) titleLabelFrame {
    
    CGFloat x,y,w,h;
    x = self.titleLeftMargin;
    y = 0;
    w = self.bounds.size.width - self.titleLeftMargin;
    h = self.bounds.size.height;
    return CGRectMake(x, y, w, h);
    
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = [self titleLabelFrame];
    
}

- (void) setTitleLeftMargin:(CGFloat)titleLeftMargin {
    if (_titleLeftMargin != titleLeftMargin) {
        _titleLeftMargin = titleLeftMargin;
        [self setNeedsLayout];
    }
}


@end
