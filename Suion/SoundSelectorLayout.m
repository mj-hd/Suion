//
//  SoundSelectorLayout.m
//  Suion
//
//  Created by mjhd on 2014/08/05.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "SoundSelectorLayout.h"
#import "SoundSelectorView.h"

@implementation SoundSelectorLayout
{
    float _interval;
    CGSize _cellSize;
    float _distanceZ;
    float _centerRateThreshold;
    float _margin;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    _distanceZ = 100.0f;
    _cellSize = CGSizeMake(100.0f, 100.0f);
    _interval = self.collectionView.frame.size.width / 6.0f;
    _centerRateThreshold = _interval / 100.0f;
    _margin = (self.collectionView.frame.size.width - _cellSize.width)/2.0f;
}

- (CGSize)collectionViewContentSize {
    CGSize size = CGSizeMake(
                             [self.collectionView numberOfItemsInSection:0] *_interval,
                             self.collectionView.frame.size.height
                             );
    size.width += _margin*2.0f +_cellSize.width/2.0f +10.0f; // 先頭と末尾のマージンを足す
    
    return size;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
    
    float originWithMargin = rect.origin.x - _margin + 5.0f;
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int i = MAX(0, (int)(originWithMargin / _interval));
    
    for (;
         i < [self.collectionView numberOfItemsInSection:0] &&
         (i-1)*_interval < (originWithMargin + rect.size.width);
         i++) {
        [result addObject:
         [NSIndexPath indexPathForItem:i inSection:0]];
    }
    
    return result;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *indexPaths = [self indexPathsForItemsInRect:rect];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:indexPaths.count];
    
    for (NSIndexPath *path in indexPaths) {
        [result addObject:[self layoutAttributesForItemAtIndexPath:path]];
    }
    
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewLayoutAttributes *att = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGRect frame;
    frame.origin.x = indexPath.item * _interval + _margin;
    frame.origin.y = (self.collectionView.frame.size.height
                      - _cellSize.height) / 2.0f;
    frame.size = _cellSize;
    
    att.frame = frame;
    att.transform3D = [self transformWithCellOffsetX:frame.origin.x];
    
    return att;
}

- (bool)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGPoint theTargetContentOffset = proposedContentOffset;
    
    theTargetContentOffset.x = roundf(theTargetContentOffset.x / _interval) * _interval;
    theTargetContentOffset.x = MIN(theTargetContentOffset.x, ([self.collectionView numberOfItemsInSection:0] - 1) * _interval);
    
    int i = (theTargetContentOffset.x + _cellSize.width/2.0f) / _interval;
    NSIndexPath *targetPath = [NSIndexPath indexPathForItem:i inSection:0];
    [((SoundSelectorView *)self.collectionView) selectCell:targetPath];
    
    return theTargetContentOffset;
}

- (CATransform3D)transformWithCellOffsetX:(float)offsetX {
    
    // offsetXの値を、-1.0f ~ 1.0fの値として返す。
    float distanceRate = [self rateForCellOffsetX:offsetX];
    
    CATransform3D t = CATransform3DIdentity;
    
    // 視点の設定
    t.m34 = 1.0f / -_distanceZ;
    
    // 位置を調節
    t = CATransform3DTranslate(t,
                               [self translateXForDistanceRate:distanceRate],
                               0.0f,
                               [self translateZForDistanceRate:distanceRate]);
    
    // 角度を調節
    t = CATransform3DRotate(t,
                            [self angleForDistanceRate:distanceRate],
                            0.0f, 1.0f, 0.0f);
    
    return t;
}

- (float)rateForCellOffsetX:(float)offsetX {
    CGFloat bw = self.collectionView.bounds.size.width;
    CGFloat offsetFromCenter = offsetX + _cellSize.width/2 - (self.collectionView.contentOffset.x + bw /2);
    CGFloat rate = offsetFromCenter / bw;
    return MIN(MAX(-1.0, rate), 1.0);
}

- (float)translateXForDistanceRate:(float)distanceRate {
    
    if (fabsf(distanceRate) < _centerRateThreshold) {
        return (distanceRate / _centerRateThreshold) * (_cellSize.width / 2.0f);
    }
    return copysignf(1.0f, distanceRate) * (_cellSize.width / 2.0f);
}

- (float)translateZForDistanceRate:(float)distanceRate {
    
    if (fabsf(distanceRate) < _centerRateThreshold) {
        return -1.0f -2.0f * _cellSize.width * (1.0f - cos((distanceRate / _centerRateThreshold) * M_PI_2));
    }
    return -1.0f -2.0f * _cellSize.width;
}

- (float)angleForDistanceRate:(float)distanceRate {
    static const float baseAngle = -M_PI * 90 / 180;
    
    if (fabsf(distanceRate) > _centerRateThreshold) {
        return copysignf(1.0f, distanceRate) * baseAngle;
    }
    return (distanceRate /_centerRateThreshold) * baseAngle;
}

@end
