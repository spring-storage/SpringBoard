//
//  WBSpringBoardCombinedCell.h
//  Pods
//
//  Created by LIJUN on 2017/3/10.
//
//

#import <SpringBoard/SpringBoard.h>

@interface WBSpringBoardCombinedCell : WBSpringBoardCell

@property (nonatomic, readonly) UIView *directoryView;
@property (nonatomic, readonly) UILabel *folderLabel;

- (void)refreshSubImageNames:(NSArray<NSString *> *)imageNameArray;
- (void)refreshSubImages:(NSArray<UIImage *> *)imageArray;

@end
