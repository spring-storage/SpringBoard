//
//  WBSpringBoard.m
//  Pods
//
//  Created by LIJUN on 2017/3/7.
//
//

#import "WBSpringBoard.h"
#import "WBSpringBoardDefines.h"
#import "WBSpringBoardLayout.h"
#import "WBSpringBoardCell.h"
#import "WBIndexRect.h"
#import "UIView+Layout.h"

@interface WBSpringBoard () <UIScrollViewDelegate, WBSpringBoardCellDelegate, WBSpringBoardCellLongGestureDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, strong) WBSpringBoardCell *dragCell;

@property (nonatomic, assign) NSInteger numberOfItems;

@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger colsPerPage;
@property (nonatomic, assign) NSInteger rowsPerPage;

@property (nonatomic, strong) NSMutableArray *frameContainerArray;
@property (nonatomic, strong) NSMutableArray *contentIndexRectArray;
@property (nonatomic, strong) NSMutableArray *contentCellArray;

@property (nonatomic, assign) BOOL isDrag;
@property (nonatomic, assign) NSInteger dragFromIndex;

@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGPoint previousMovePointAtWindow;

@end

@implementation WBSpringBoard

#define kDragScaleFactor 1.2
#define kScrollViewDragBoundaryThreshold 30

#pragma mark - Init & Dealloc

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Private Method

- (void)commonInit
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
    [scrollView layoutWithHorizontalAlignment:HStretch
                        withVerticalAlignment:VStretch
                                   withMargin:ThicknessZero()];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    pageControl.enabled = NO;
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    pageControl.numberOfPages = 1;
    [self addSubview:pageControl];
    _pageControl = pageControl;

    [pageControl sizeToFit];
    [pageControl layoutWithHorizontalAlignment:HCenter
                         withVerticalAlignment:VBottom
                                    withMargin:ThicknessZero()];
    
    _layout = [[WBSpringBoardLayout alloc] init];
    
    _frameContainerArray = [NSMutableArray array];
    _contentIndexRectArray = [NSMutableArray array];
    _contentCellArray = [NSMutableArray array];
    
    [self reloadData];
}

- (void)layoutContentCells
{
    __weak __typeof(self)weakSelf = self;
    
    [self computePages];
    [self computeFrameContainers];

    [_contentIndexRectArray removeAllObjects];
    for (UIView *view in _contentCellArray) {
        [view removeFromSuperview];
    }
    [_contentCellArray removeAllObjects];
    
    for (NSInteger i = 0; i < _numberOfItems; i ++) {
        WBSpringBoardCell *cell = nil;
        if (_dataSource) {
            NSAssert([_dataSource respondsToSelector:@selector(springBoard:cellForItemAtIndex:)], @"@selector(springBoard:cellForItemAtIndex:) must be implemented");
            cell = [_dataSource springBoard:weakSelf cellForItemAtIndex:i];
        } else {
            cell = [[WBSpringBoardCell alloc] init];
        }
        cell.frame = CGRectFromString(_frameContainerArray[i]);
        cell.delegate = self;
        cell.longGestureDelegate = self;
        
        
        [_contentIndexRectArray addObject:[[WBIndexRect alloc] initWithIndex:i rect:cell.frame]];
        [_contentCellArray addObject:cell];
        [_scrollView addSubview:cell];
    }

    CGAffineTransform t = CGAffineTransformMakeScale(_pages, 1);
    if (_layout.scrollDirection == WBSpringBoardScrollDirectionVertical) {
        t = CGAffineTransformMakeScale(1, _pages);
    }
    _scrollView.contentSize = CGSizeApplyAffineTransform(_scrollView.bounds.size, t);
    
    _pageControl.numberOfPages = _pages;
    _pageControl.currentPage = 0;
}

- (void)computePages
{
    CGSize scrollViewSize = _scrollView.bounds.size;
    CGFloat maximumContentWidth = scrollViewSize.width - (_layout.insets.left + _layout.insets.right);
    CGFloat maximumContentHeight = scrollViewSize.height - (_layout.insets.top + _layout.insets.bottom);

    _colsPerPage = (maximumContentWidth + _layout.minimumHorizontalSpace) / (_layout.itemSize.width + _layout.minimumHorizontalSpace);
    _rowsPerPage = (maximumContentHeight + _layout.minimumVerticalSpace) / (_layout.itemSize.height + _layout.minimumVerticalSpace);
    
    NSInteger onePageMaxItems = _colsPerPage * _rowsPerPage;
    _pages = MAX((_numberOfItems + (onePageMaxItems - 1)) / onePageMaxItems, 1);
}

- (void)computeFrameContainers
{
    [_frameContainerArray removeAllObjects];
    
    CGSize scrollViewSize = _scrollView.bounds.size;
    CGSize itemSize = _layout.itemSize;
    CGFloat itemHSpace = (scrollViewSize.width - (_layout.insets.left + _layout.insets.right) - _colsPerPage * itemSize.width) / (_colsPerPage - 1);
    CGFloat itemVSpace = (scrollViewSize.height - (_layout.insets.top + _layout.insets.bottom) - _rowsPerPage * itemSize.height) / (_rowsPerPage - 1);
    
    for (NSInteger page = 0; page < _pages; page ++) {
        for (NSInteger row = 0; row < _rowsPerPage; row ++) {
            for (NSInteger col = 0; col < _colsPerPage; col ++) {
                CGRect frame = CGRectZero;
                frame.size = itemSize;
                
                frame.origin.x = page * scrollViewSize.width + _layout.insets.left + (itemSize.width + itemHSpace) * col;
                frame.origin.y = _layout.insets.top + (itemSize.height + itemVSpace) * row;
                if (_layout.scrollDirection == WBSpringBoardScrollDirectionVertical) {
                    frame.origin.x = _layout.insets.left + (itemSize.width + itemHSpace) * col;
                    frame.origin.y = page * scrollViewSize.height + _layout.insets.top + (itemSize.height + itemVSpace) * row;
                }
                
                [_frameContainerArray addObject:NSStringFromCGRect(frame)];
            }
        }
    }
}

- (NSInteger)indexForCell:(WBSpringBoardCell *)cell
{
    return [_contentCellArray indexOfObject:cell];
}

- (WBSpringBoardCell *)dragCellWithCell:(WBSpringBoardCell *)cell
{
    _isDrag = YES;
    if (_dragCell) {
        return _dragCell;
    }
    
    CGRect frame = cell.frame;
    CGRect dragFrameInWindow = [cell.superview convertRect:frame toView:kAppKeyWindow];
    
    _dragCell = [[[cell class] alloc] init];
    _dragCell.frame = dragFrameInWindow;
    [kAppKeyWindow addSubview:_dragCell];
    
    return _dragCell;
}

- (double)fingerMoveSpeedWithPreviousPoint:(CGPoint)prePoint nowPoint:(CGPoint)nowPoint
{
    double x = pow(prePoint.x - nowPoint.x, 2);
    double y = pow(prePoint.y - nowPoint.y, 2);
    return sqrt(x + y);
}

- (NSDictionary *)targetInfoWithPoint:(CGPoint)scrollPoint
{
    NSMutableDictionary *dict = [@{@"targetIndex": @(-1), @"innerRect": @(NO)} mutableCopy];
    for (WBIndexRect *indexRect in _contentIndexRectArray) {
        if (CGRectContainsPoint(indexRect.rect, scrollPoint)) {
            dict[@"targetIndex"] = @(indexRect.index);
            if (CGRectContainsPoint(indexRect.innerRect, scrollPoint)) {
                dict[@"innerRect"] = @(YES);
            }
            
            break;
        }
    }
    return dict;
}

- (void)toPageWithPoint:(CGPoint)scrollPoint
{
    CGRect scrollViewLeftSideRect = CGRectMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y, kScrollViewDragBoundaryThreshold, CGRectGetHeight(_scrollView.frame));
    CGRect scrollViewRightSideRect = CGRectMake(_scrollView.contentOffset.x + CGRectGetWidth(_scrollView.frame) - kScrollViewDragBoundaryThreshold, _scrollView.contentOffset.y, kScrollViewDragBoundaryThreshold, CGRectGetHeight(_scrollView.frame));
    
    if (CGRectContainsPoint(scrollViewLeftSideRect, scrollPoint)) {
        if (_pageControl.currentPage > 0) {
            _pageControl.currentPage -= 1;
            CGPoint offset = CGPointMake(_pageControl.currentPage * CGRectGetWidth(_scrollView.frame), 0);
            [_scrollView setContentOffset:offset animated:YES];
        }
    } else if (CGRectContainsPoint(scrollViewRightSideRect, scrollPoint)) {
        if (_pageControl.currentPage < _pageControl.numberOfPages - 1) {
            _pageControl.currentPage += 1;
            CGPoint offset = CGPointMake(_pageControl.currentPage * CGRectGetWidth(_scrollView.frame), 0);
            [_scrollView setContentOffset:offset animated:YES];
        }
    }
}

#pragma mark - Setter & Getter

- (void)setLayout:(WBSpringBoardLayout *)layout
{
    _layout = layout;
    
    [self reloadData];
}

- (void)setDataSource:(id<WBSpringBoardDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

- (void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
    
    for (WBSpringBoardCell *cell in _contentCellArray) {
        cell.isEdit = isEdit;
    }
}

#pragma mark - Public Method

- (void)reloadData
{
    __weak __typeof(self)weakSelf = self;
    
    _numberOfItems = 0;
    if (_dataSource) {
        NSAssert([_dataSource respondsToSelector:@selector(numberOfItemsInSpringBoard:)], @"@selector(numberOfItemsInSpringBoard:) must be implemented");
        _numberOfItems = [_dataSource numberOfItemsInSpringBoard:weakSelf];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self layoutContentCells];
    });
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_layout.scrollDirection == WBSpringBoardScrollDirectionHorizontal) {
        _pageControl.currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    } else if (_layout.scrollDirection == WBSpringBoardScrollDirectionVertical) {
        _pageControl.currentPage = scrollView.contentOffset.y / scrollView.bounds.size.height;
    }
}

#pragma mark - WBSpringBoardCellDelegate Method

- (void)clickSpringBoardCell:(WBSpringBoardCell *)cell
{
    if (self.isEdit) {
        self.isEdit = NO;
    }
}

- (void)editingSpringBoardCell:(WBSpringBoardCell *)cell
{
    self.isEdit = YES;
    
    _dragFromIndex = [self indexForCell:cell];
    NSLog(@"%ld", _dragFromIndex);
    
    WBSpringBoardCell *dragCell = [self dragCellWithCell:cell];
    dragCell.backgroundColor = [UIColor redColor];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        dragCell.transform = CGAffineTransformMakeScale(kDragScaleFactor, kDragScaleFactor);
        dragCell.alpha = 0.8;
    }];
}

#pragma mark - WBSpringBoardCellLongGestureDelegate Method

- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateBegin:(UILongPressGestureRecognizer *)gesture
{
    cell.hidden = YES;
    
    CGPoint beginPoint = [gesture locationInView:cell];
    _lastPoint = CGPointApplyAffineTransform(beginPoint, CGAffineTransformMakeScale(kDragScaleFactor, kDragScaleFactor));
    CGPoint pointAtWindow = [gesture locationInView:kAppKeyWindow];
    _previousMovePointAtWindow = pointAtWindow;
}

- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateMove:(UILongPressGestureRecognizer *)gesture
{
    CGPoint pointAtWindow = [gesture locationInView:kAppKeyWindow];
    CGPoint currentOrigin = CGPointMake(pointAtWindow.x - _lastPoint.x, pointAtWindow.y - _lastPoint.y);
    if (_isDrag) {
        CGRect dragFrame = _dragCell.frame;
        dragFrame.origin = currentOrigin;
        _dragCell.frame = dragFrame;
        
        CGPoint scrollPoint = [gesture locationInView:_scrollView];

        double fingerSpeed = [self fingerMoveSpeedWithPreviousPoint:_previousMovePointAtWindow nowPoint:pointAtWindow];
        _previousMovePointAtWindow = pointAtWindow;
        if (fingerSpeed < 2) {
            NSDictionary *targetInfo = [self targetInfoWithPoint:scrollPoint];
            NSLog(@"%@", targetInfo);
            
            NSInteger targetIndex = targetInfo[@"targetIndex"];
            if (targetIndex > 0 && targetIndex != _dragFromIndex) {
                
            }
        }
        
        [self toPageWithPoint:scrollPoint];
    }
}

- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateEnd:(UILongPressGestureRecognizer *)gesture
{
    cell.hidden = NO;
    
    if (_isDrag) {
        _isDrag = NO;
        
        [_dragCell removeFromSuperview];
        _dragCell = nil;
    }
}

- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateCancel:(UILongPressGestureRecognizer *)gesture
{
    cell.hidden = NO;

    if (_isDrag) {
        _isDrag = NO;
        
        [_dragCell removeFromSuperview];
        _dragCell = nil;
    }
}

@end