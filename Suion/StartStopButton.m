//
//  StartStopButton.m
//  Suion
//
//  Created by mjhd on 2014/08/04.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "StartStopButton.h"

@implementation StartStopButton
{
    bool _isStarted;
}
- (void)setup {
    _isStarted = false;
    [self setTitle:@"START" forState:UIControlStateNormal];
    [self setTitle:@"STOP" forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    // 背景透明
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}



- (void)setNormalColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0f);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(c, r, g, b, a);
    CGContextFillEllipseInRect(c, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height));
    
    UIImage *normalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
}

-(void)setPressedColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 2.0f);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(c, r, g, b, a);
    CGContextFillEllipseInRect(c, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height));
    
    UIImage *pressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:pressedImage forState:UIControlStateSelected];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    _isStarted = !_isStarted;
    if (_isStarted) {
        // STOPにする
        [self setSelected:YES];
    } else {
        // STARTにする
        [self setSelected:NO];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
