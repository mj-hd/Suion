//
//  BlurImageView.m
//  Suion
//
//  Created by mjhd on 2014/08/07.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "BlurImageView.h"
#import "UIImage+BlurredFrame.h"

@implementation BlurImageView

- (void)setup {
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

/*- (void)drop:(CGPoint)point {
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:c];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endDrop)];
    
    
    
    [UIView commitAnimations];
}

- (void)endDrop {
    
}*/

- (void)setImage:(UIImage *)image {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(applyEffect:) object:image];
    [thread start];
}

- (void)applyEffect:(UIImage *)image {
    CGRect frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    image = [image applyBlurWithRadius:2.0f tintColor:[UIColor colorWithWhite:1.0f alpha:0.2f] saturationDeltaFactor:1.0f maskImage:NULL atFrame:frame];
    [super setImage:image];
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
