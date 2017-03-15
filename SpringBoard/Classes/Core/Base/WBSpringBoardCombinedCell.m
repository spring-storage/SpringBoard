//
//  WBSpringBoardCombinedCell.m
//  Pods
//
//  Created by LIJUN on 2017/3/10.
//
//

#import "WBSpringBoardCombinedCell.h"
#import <Masonry/Masonry.h>
#import "WBSpringBoardDefines.h"

@interface WBSpringBoardCombinedCell ()

@property (nonatomic, strong) NSMutableArray *imageViewColArray;
@property (nonatomic, strong) NSMutableArray *imageViewRowArray;

@end

@implementation WBSpringBoardCombinedCell

#define kViewCornerRadius 10
#define kImageViewSpacing 5
#define kImageViewCornerRadius 5

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageView.hidden = YES;
        
        UIView *directoryView = [[UIView alloc] init];
        directoryView.backgroundColor = [UIColor lightGrayColor];
        directoryView.layer.cornerRadius = kViewCornerRadius;
        directoryView.userInteractionEnabled = NO;
        [self addSubview:directoryView];
        _directoryView = directoryView;
        
        [directoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.imageView);
        }];
        
        
        _imageViewColArray = [NSMutableArray array];
        _imageViewRowArray = [NSMutableArray array];
        
        for (NSInteger row = 0; row < kCombinedCellShowItemRowCount; row ++) {
            [_imageViewRowArray addObject:[NSMutableArray array]];
        }
        for (NSInteger col = 0; col < kCombinedCellShowItemColCount; col ++) {
            [_imageViewColArray addObject:[NSMutableArray array]];
        }
        for (NSInteger row = 0; row < kCombinedCellShowItemRowCount; row ++) {
            for (NSInteger col = 0; col < kCombinedCellShowItemColCount; col ++) {
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.backgroundColor = [UIColor grayColor];
                imageView.layer.cornerRadius = kImageViewCornerRadius;
                imageView.layer.masksToBounds = YES;
                [directoryView addSubview:imageView];

                _imageViewRowArray[row][col] = imageView;
                _imageViewColArray[col][row] = imageView;
            }
        }
        
        for (NSInteger row = 0; row < kCombinedCellShowItemRowCount; row ++) {
            [_imageViewRowArray[row] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:5 leadSpacing:5 tailSpacing:5];
        }
        for (NSInteger col = 0; col < kCombinedCellShowItemColCount; col ++) {
            [_imageViewColArray[col] mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:5 leadSpacing:5 tailSpacing:5];
        }
    }
    return self;
}

@end
