//
//  SoundSelectorView.h
//  Suion
//
//  Created by mjhd on 2014/08/06.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundSelectorCellAttribute : NSObject

@property (retain, nonatomic) UIView *backgroundView;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *label;


@end

@interface SoundSelectorView : UICollectionView

@property (copy, nonatomic) void (^selected)(NSIndexPath *indexPath, SoundSelectorCellAttribute *cell);

- (void)appendCell:(SoundSelectorCellAttribute *)attribute;
- (void)selectCell:(NSIndexPath*)indexPath;
@end
