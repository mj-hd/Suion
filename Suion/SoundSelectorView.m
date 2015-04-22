//
//  SoundSelectorView.m
//  Suion
//
//  Created by mjhd on 2014/08/06.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "SoundSelectorView.h"

@implementation SoundSelectorCellAttribute
@end

@implementation SoundSelectorView
{
    NSMutableArray *_cells;
}

- (void)setup {
    self.delegate = self;
    self.dataSource = self;
    
    self.allowsSelection = YES;
    self.allowsMultipleSelection = NO;
    
    // 透過
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    
    _cells = [[NSMutableArray alloc] init];
    self.selected = ^(NSIndexPath *i, SoundSelectorCellAttribute *s) {};
}

- (id)initWithCoder:(NSCoder *)aDecoder {
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

- (void)appendCell:(SoundSelectorCellAttribute *)att {
    [_cells addObject:att];
}
- (void)selectCell:(NSIndexPath*)indexPath {
    [[self cellForItemAtIndexPath:indexPath] setSelected:YES];
    [self collectionView:self didSelectItemAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_cells count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    ((UILabel *)[cell viewWithTag:1]).text = ((SoundSelectorCellAttribute *)_cells[indexPath.item]).label;
    cell.backgroundView = ((SoundSelectorCellAttribute *)_cells[indexPath.item]).backgroundView;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selected(indexPath, _cells[indexPath.item]);
    [self selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

@end
