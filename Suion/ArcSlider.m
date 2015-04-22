//
//  ArcSlider.m
//  Suion
//
//  Created by mjhd on 2014/08/04.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "ArcSlider.h"

@implementation ArcSlider
{
    float _volume;
    CGFloat _r;
    CGFloat _g;
    CGFloat _b;
    CGFloat _a;
    bool _isSettled;
}

- (void)setup {
    // 背景透明
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    
    self.changed = ^(float v) {};
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

- (float)volume
{
    return _volume;
}
- (void)setVolume:(float)value
{
    _volume = value;
    
    [self drawRect:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    self.changed(_volume);
}

- (void)setColor:(UIColor *)color {
    [color getRed:&_r green:&_g blue:&_b alpha:&_a];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (c == NULL) return;
    
    CGContextSetRGBFillColor(c, _r, _g, _b, _a);

    CGFloat arcCenterPointX = self.frame.size.width/2.0f;
    CGFloat arcCenterPointY = self.frame.size.height/2.0f;
    CGFloat arcOuterBeginPointX = arcCenterPointX;
    CGFloat arcOuterBeginPointY = 0;
    CGFloat arcInnerBeginPointX = arcOuterBeginPointX;
    CGFloat arcInnerBeginPointY = arcOuterBeginPointY + 15.0f;
    CGFloat currentRadian = _volume * (2.0f * M_PI) - M_PI_2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // 外側の円弧
    CGPathMoveToPoint(path, NULL, arcCenterPointX, arcCenterPointY);
    CGPathAddLineToPoint(path, NULL, arcOuterBeginPointX, arcOuterBeginPointY);
    CGPathAddArc(path, NULL, arcCenterPointX, arcCenterPointY, self.frame.size.width/2.0f, -1.0f * M_PI_2, currentRadian, NO);
    CGPathAddLineToPoint(path, NULL, arcCenterPointX, arcCenterPointY);
    CGPathCloseSubpath(path);
    
    // 内側の円
    CGPathMoveToPoint(path, NULL, arcCenterPointX, arcCenterPointY);
    CGPathAddLineToPoint(path, NULL, arcInnerBeginPointX, arcInnerBeginPointY);
    CGPathAddArc(path, NULL, arcCenterPointX, arcCenterPointY, self.frame.size.width/2.0f -20.0f, -1.0f * M_PI_2, currentRadian, NO);
    CGPathAddLineToPoint(path, NULL, arcCenterPointX, arcCenterPointY);
    CGPathCloseSubpath(path);
    
    // コンテキストにパスを追加
    CGContextAddPath(c, path);
    
    // 塗る
    CGContextEOFillPath(c);
    
    CGPathRelease(path);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSettled = false;
    
    UITouch *currentTouchedPosition = [touches anyObject];
    CGPoint position = [currentTouchedPosition locationInView:self];
    
    // 範囲外をタッチしていた場合
    if (![self isInArcSlider:position]) {
        _isSettled = true;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSettled = true;
    
    UITouch *currentTouchedPosition = [touches anyObject];
    CGPoint position = [currentTouchedPosition locationInView:self];
    
    [self updateVolumeFromPosition:position];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSettled) return;
    _isSettled = true;
    
    UITouch *currentTouchedPosition = [touches anyObject];
    CGPoint position = [currentTouchedPosition locationInView:self];
    
    [self updateVolumeFromPosition:position];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSettled) return;
    
    UITouch *currentTouchedPosition = [touches anyObject];
    CGPoint position = [currentTouchedPosition locationInView:self];
    
    [self updateVolumeFromPosition:position];
}

- (void)updateVolumeFromPosition:(CGPoint)position {
    float currentTouchedVolume = [self convertToVolume:position];
    
    // 行き過ぎを防ぐ
    if ((currentTouchedVolume < 0.25f) && (_volume > 0.75f)) {
    } else if ((currentTouchedVolume > 0.75f) && (_volume < 0.25f)) {
    } else {
        
        [self setVolume:currentTouchedVolume];
        [self setNeedsDisplay];
    }
}

- (bool)isInArcSlider:(CGPoint)point {
    float center_x = (float)self.frame.size.width / 2.0f;
    float center_y = (float)self.frame.size.height / 2.0f;
    float x = point.x - center_x;
    float y = point.y - center_y;
    float rt = sqrtf(x*x + y*y);
    float r2 = self.frame.size.width/2.0f;
    float r1 = r2-20.0f;
    return ((r1 <= rt) && (rt <= r2));
}

- (float)convertToVolume:(CGPoint)point {
    float center_x = (float)self.frame.size.width / 2.0f;
    float center_y = (float)self.frame.size.height / 2.0f;
    float x = point.x - center_x;
    float y = point.y - center_y;
    float radian = 0.0f;
    float rt = sqrtf(x*x + y*y);
    float radian_offset = 0.0f;
        
    if ((x >= 0) && (y <= 0)) {
        radian_offset = 0.0f;
        radian = asinf(fabsf(x) / rt);
    }
    if ((x > 0) && (y > 0)) {
        radian_offset = M_PI_2;
        radian = acosf(fabsf(x) / rt);
    }
    if ((x <= 0) && (y >= 0)) {
        radian_offset = M_PI;
        radian = asinf(fabsf(x) / rt);
    }
    if ((x < 0) && (y < 0)) {
        radian_offset = 3.0f*M_PI_2;
        radian = acosf(fabsf(x) / rt);
    }
        
    return (radian_offset+radian)/(2.0f*M_PI);
}


@end
