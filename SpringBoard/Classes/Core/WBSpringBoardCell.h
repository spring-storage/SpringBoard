//
//  WBSpringBoardCell.h
//  Pods
//
//  Created by LIJUN on 2017/3/7.
//
//

#import <UIKit/UIKit.h>

@class WBSpringBoardCell;

@protocol WBSpringBoardCellDelegate <NSObject>
@optional
- (void)clickSpringBoardCell:(WBSpringBoardCell *)cell;
- (void)editingSpringBoardCell:(WBSpringBoardCell *)cell;

@end

@protocol WBSpringBoardCellLongGestureDelegate <NSObject>
@optional
- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateBegin:(UILongPressGestureRecognizer *)gesture;
- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateMove:(UILongPressGestureRecognizer *)gesture;
- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateEnd:(UILongPressGestureRecognizer *)gesture;
- (void)springBoardCell:(WBSpringBoardCell *)cell longGestureStateCancel:(UILongPressGestureRecognizer *)gesture;

@end

@interface WBSpringBoardCell : UIControl

@property (nonatomic, weak) id<WBSpringBoardCellDelegate> delegate;
@property (nonatomic, weak) id<WBSpringBoardCellLongGestureDelegate> longGestureDelegate;

@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, assign) BOOL isEdit;

@end