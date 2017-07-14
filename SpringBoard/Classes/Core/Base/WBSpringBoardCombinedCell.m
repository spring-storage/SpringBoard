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
#import "NSBundle+SpringBoard.h"

@interface WBSpringBoardCombinedCell ()

@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewArray;
@property (nonatomic, strong) NSMutableArray *imageViewColArray;
@property (nonatomic, strong) NSMutableArray *imageViewRowArray;
@property (assign, nonatomic) CGSize testSize;

@end

@implementation WBSpringBoardCombinedCell

#define kViewCornerRadius 10
#define kImageViewSpacing 2
#define kImageViewCornerRadius 10

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageView.hidden = YES;
        
        UIView *directoryView = [[UIView alloc] init];
        directoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list-fiolder"]];
        directoryView.layer.cornerRadius = kViewCornerRadius;
        directoryView.userInteractionEnabled = NO;
        [self.contentView addSubview:directoryView];
        _directoryView = directoryView;
        [directoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.imageView);
        }];
        
        _imageViewArray = [NSMutableArray array];
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
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.layer.cornerRadius = kImageViewCornerRadius;
                imageView.layer.masksToBounds = YES;
                [directoryView addSubview:imageView];
                
                [_imageViewArray addObject:imageView];
                _imageViewRowArray[row][col] = imageView;
                _imageViewColArray[col][row] = imageView;
            }
        }
        
        for (NSInteger row = 0; row < kCombinedCellShowItemRowCount; row ++) {
            [_imageViewRowArray[row] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:kImageViewSpacing leadSpacing:kImageViewSpacing tailSpacing:kImageViewSpacing];
        }
        for (NSInteger col = 0; col < kCombinedCellShowItemColCount; col ++) {
            [_imageViewColArray[col] mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:kImageViewSpacing leadSpacing:kImageViewSpacing tailSpacing:kImageViewSpacing];
        }
        UIImageView *folderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folderTest"]];
        folderImageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:folderImageView];
        [folderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.imageView);
        }];
        folderImageView.layer.masksToBounds = YES;
        folderImageView.layer.cornerRadius = 10;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        //        label.textColor = [UIColor colorWithRed:52.f/255.f green:52.f/255.f blue:52.f/255.f alpha:1.0];
        label.textColor = [UIColor whiteColor];
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setFrame:CGRectMake(0, folderImageView.frame.size.height - 69.f, folderImageView.frame.size.width, 69.f)];
        [folderImageView addSubview:label];
        _folderLabel = label;
        
        CGSize size = CGSizeZero;
        
        if (IDIOM == IPAD) {
            size.width = screenWidth/4-16;
        } else {
            size.width = screenWidth/2-16;
        }
        size.height = size.width*1.25;
        self.testSize = size;
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(folderImageView.mas_bottom).offset(-69);
            //            make.width.mas_lessThanOrEqualTo(imageView).offset(-1 * kLabelWidthOffset);
            make.width.mas_equalTo(self.testSize.width);
            //            make.height.mas_equalTo(label.font.lineHeight);
            make.height.mas_equalTo(69);
        }];
    }
    return self;
}

- (void)refreshSubImageNames:(NSArray<NSString *> *)imageNameArray
{
    NSMutableArray<UIImage *> *imageArray = [NSMutableArray array];
    for (NSString *imageName in imageNameArray) {
        UIImage *image = [UIImage imageNamed:imageName];
        if (!image) {
            image = [NSBundle wb_icoImage];
        }
        [imageArray addObject:image];
    }
    [self refreshSubImages:imageArray];
}

- (void)refreshSubImages:(NSArray<UIImage *> *)imageArray
{
    for (NSInteger i = 0; i < _imageViewArray.count; i ++) {
        UIImage *image = (i < imageArray.count) ? imageArray[i] : nil;
        _imageViewArray[i].image = image;
    }
}

@end
