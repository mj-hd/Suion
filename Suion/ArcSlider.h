//
//  ArcSlider.h
//  Suion
//
//  Created by mjhd on 2014/08/04.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArcSlider : UIView

@property (copy, nonatomic) void (^changed)(float volume);

- (float)volume;
- (void)setVolume:(float)value;
- (void)setColor:(UIColor *)color;

@end
