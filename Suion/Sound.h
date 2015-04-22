//
//  Sound.h
//  Suion
//
//  Created by mjhd on 2014/08/07.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sound : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *shortName;
@property (copy, nonatomic) NSString *soundFile;
@property (retain, nonatomic) UIImage *largeImage;
@property (retain, nonatomic) UIImage *smallImage;
@property (retain, nonatomic) UIColor *baseColor;

+ (void)prepare;
+ (void)dealloc;
- (void)prepare;
- (void)dealloc;
- (void)playLoop;
- (void)stop;
- (void)setVolume:(float)volume;

@end
