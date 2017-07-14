//
//  WBSpringBoardCell.m
//  Pods
//
//  Created by LIJUN on 2017/3/7.
//
//

#import "WBSpringBoardCell.h"
#import "WBSpringBoardDefines.h"
#import <Masonry/Masonry.h>
#import "NSBundle+SpringBoard.h"
#import <Foundation/Foundation.h>

@interface WBSpringBoardCell ()

@property (nonatomic, weak) UIView *directoryHolderView;
@property (assign, nonatomic) CGSize testSize;

@end

@implementation WBSpringBoardCell

#define kImageViewSize CGSizeMake(70, 70)
#define kImageViewCornerRadius 10
#define kLabelFontSize 17
#define kLabelPaddingTop 2
#define kLabelWidthOffset 10

#define kViewScaleFactor 1.2
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define IPAD     UIUserInterfaceIdiomPad
#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureAction:)];
        [self addGestureRecognizer:_longGesture];
        
        UIView *contentView = [UIView new];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.userInteractionEnabled = NO;
        [self addSubview:contentView];
        _contentView = contentView;
        
        UIView *directoryHolderView = [[UIView alloc] initWithFrame:CGRectZero];
        
        directoryHolderView.backgroundColor = [UIColor colorWithRed:59.f/255.f green:124.f/255.f blue:210.f/255.f alpha:1];
        directoryHolderView.layer.cornerRadius = kImageViewCornerRadius;
        directoryHolderView.userInteractionEnabled = NO;
        directoryHolderView.hidden = YES;
        [contentView addSubview:directoryHolderView];
        _directoryHolderView = directoryHolderView;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [NSBundle wb_icoImage];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = kImageViewCornerRadius;
        imageView.layer.masksToBounds = YES;
        [contentView addSubview:imageView];
        _imageView = imageView;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kLabelFontSize];
        label.textColor = [UIColor colorWithRed:52.f/255.f green:52.f/255.f blue:52.f/255.f alpha:1.0];
        [label setBackgroundColor:[UIColor colorWithRed:212.f/255.f green:212.f/255.f blue:212.f/255.f alpha:0.8f]];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setFrame:CGRectMake(0, imageView.frame.size.height - 69.f, imageView.frame.size.width, 69.f)];
        [imageView addSubview:label];
        _label = label;
        
        UIImageView *editImageView = [[UIImageView alloc] init];
        editImageView.image = [UIImage imageNamed:@"list-black"];
        editImageView.contentMode = UIViewContentModeScaleToFill;
        editImageView.alpha = 0.4f;
        editImageView.layer.cornerRadius = kImageViewCornerRadius;
        editImageView.layer.masksToBounds = YES;
        [contentView addSubview:editImageView];
        _editImageView = editImageView;
        
        UIImageView *checkImageView = [[UIImageView alloc] init];
        checkImageView.contentMode = UIViewContentModeScaleToFill;
        checkImageView.alpha = 0.8f;
        [contentView addSubview:checkImageView];
        _checkImageView = checkImageView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.mas_equalTo(imageView);
            make.bottom.mas_equalTo(label);
        }];
        
        [directoryHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(imageView);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(contentView);
            make.top.mas_equalTo(contentView);
            CGSize size = CGSizeZero;
            
            if (IDIOM == IPAD) {
                size.width = screenWidth/4-16;
            } else {
                size.width = screenWidth/2-16;
            }
            size.height = size.width*1.25;
            self.testSize = size;
            make.size.mas_equalTo(size);
        }];
        
        [editImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(contentView);
            make.top.mas_equalTo(contentView);
            CGSize size = CGSizeZero;
            
            if (IDIOM == IPAD) {
                size.width = screenWidth/4-16;
            } else {
                size.width = screenWidth/2-16;
            }
            size.height = size.width*1.25;
            self.testSize = size;
            make.size.mas_equalTo(size);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(imageView.mas_bottom).offset(-69);
            //            make.width.mas_lessThanOrEqualTo(imageView).offset(-1 * kLabelWidthOffset);
            make.width.mas_equalTo(self.testSize.width);
            //            make.height.mas_equalTo(label.font.lineHeight);
            make.height.mas_equalTo(69);
        }];
        
        [checkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(30);
            make.top.mas_equalTo(8);
            make.right.mas_equalTo(-8);
            
        }];
        
        // process set nil image problems
        [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [_imageView removeObserver:self forKeyPath:@"image"];
}

#pragma mark - Override Method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *image = [change valueForKey:NSKeyValueChangeNewKey];
        if (![image isKindOfClass:[UIImage class]]) {
            _imageView.image = [NSBundle wb_icoImage];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Setter & Getter

- (void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
    
    [self.layer removeAnimationForKey:@"rocking"];
    //    if (isEdit) {
    //        CAKeyframeAnimation *rockAnimation = [CAKeyframeAnimation animation];
    //        rockAnimation.keyPath = @"transform.rotation";
    //        rockAnimation.values = @[@(AngleToRadian(-3)),@(AngleToRadian(3)),@(AngleToRadian(-3))];
    //        rockAnimation.repeatCount = MAXFLOAT;
    //        rockAnimation.duration = kAnimationDuration;
    //        rockAnimation.removedOnCompletion = NO;
    //        [self.layer addAnimation:rockAnimation forKey:@"rocking"];
    //    }
}

- (void)setShowDirectoryHolderView:(BOOL)showDirectoryHolderView
{
    if (_showDirectoryHolderView != showDirectoryHolderView) {
        _showDirectoryHolderView = showDirectoryHolderView;
        
        if (showDirectoryHolderView) {
            _directoryHolderView.hidden = NO;
            [UIView animateWithDuration:kAnimationSlowDuration animations:^{
                _directoryHolderView.layer.affineTransform = CGAffineTransformMakeScale(kViewScaleFactor, kViewScaleFactor);
            }];
        } else {
            [UIView animateWithDuration:kAnimationSlowDuration animations:^{
                _directoryHolderView.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _directoryHolderView.hidden = YES;
            }];
        }
    }
}

#pragma mark - Private Method

- (void)clickAction:(id)sender
{
    @WBWeakObj(self);
    if (_delegate && [_delegate respondsToSelector:@selector(clickSpringBoardCell:)]) {
        [_delegate clickSpringBoardCell:weakself];
    }
}

- (void)longGestureAction:(UILongPressGestureRecognizer *)gesture
{
    @WBWeakObj(self);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(editingSpringBoardCell:)]) {
                [_delegate editingSpringBoardCell:weakself];
            }
            if (_longGestureDelegate && [_longGestureDelegate respondsToSelector:@selector(springBoardCell:longGestureStateBegin:)]) {
                [_longGestureDelegate springBoardCell:weakself longGestureStateBegin:gesture];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (_longGestureDelegate && [_longGestureDelegate respondsToSelector:@selector(springBoardCell:longGestureStateMove:)]) {
                [_longGestureDelegate springBoardCell:weakself longGestureStateMove:gesture];
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            if (_longGestureDelegate && [_longGestureDelegate respondsToSelector:@selector(springBoardCell:longGestureStateCancel:)]) {
                [_longGestureDelegate springBoardCell:weakself longGestureStateCancel:gesture];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (_longGestureDelegate && [_longGestureDelegate respondsToSelector:@selector(springBoardCell:longGestureStateEnd:)]) {
                [_longGestureDelegate springBoardCell:weakself longGestureStateEnd:gesture];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Public Method

- (void)setImageSize:(CGSize)size
{
    [_imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
}

@end
