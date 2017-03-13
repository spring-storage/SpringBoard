//
//  WBViewController.m
//  SpringBoard
//
//  Created by LiJun on 03/06/2017.
//  Copyright (c) 2017 LiJun. All rights reserved.
//

#import "WBViewController.h"
#import <SpringBoard/SpringBoard.h>
#import "WBCustomerCell.h"
#import "WBCustomerCombinedCell.h"

@interface WBViewController () <WBSpringBoardDelegate, WBSpringBoardDataSource>

@property (weak, nonatomic) IBOutlet WBSpringBoard *springBoard;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _dataArray = [NSMutableArray array];
    for (int i = 0; i < 70; i ++) {
        if (i == 2) {
            NSMutableArray *marr = [NSMutableArray array];
            for (int j = 0; j < 10; j ++) {
                [marr addObject:[NSString stringWithFormat:@"c%d", j]];
            }
            [_dataArray addObject:marr];
        }
        [_dataArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    _springBoard.delegate = self;
    _springBoard.dataSource = self;
    _springBoard.layout.insets = UIEdgeInsetsMake(20, 5, 30, 5);
    _springBoard.layout.minimumHorizontalSpace = 5;
    _springBoard.allowCombination = YES;
    _springBoard.allowOverlapCombination = NO;
    
    _springBoard.popupLayout.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    _springBoard.popupLayout.minimumHorizontalSpace = 5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WBSpringBoardDelegate Method

#pragma mark - WBSpringBoardDataSource Method

- (NSInteger)numberOfItemsInSpringBoard:(WBSpringBoard *)springBoard
{
    return _dataArray.count;
}

- (WBSpringBoardCell *)springBoard:(WBSpringBoard *)springBoard cellForItemAtIndex:(NSInteger)index
{
    id data = _dataArray[index];
    
    WBSpringBoardCell *cell = nil;
    if ([data isKindOfClass:NSString.class]) {
        WBCustomerCell *customerCell = [[WBCustomerCell alloc] init];
        customerCell.backgroundColor = [UIColor lightGrayColor];
        customerCell.label.text = (NSString *)data;
        
        cell = customerCell;
    } else if ([data isKindOfClass:NSArray.class]) {
        WBCustomerCombinedCell *customerCombinedCell = [[WBCustomerCombinedCell alloc] init];
        customerCombinedCell.backgroundColor = [UIColor darkGrayColor];
        customerCombinedCell.label.text = [((NSArray *)data) componentsJoinedByString:@","];
        
        cell = customerCombinedCell;
    }
    
    return cell;
}

- (NSInteger)springBoard:(WBSpringBoard *)springBoard numberOfSubItemsAtIndex:(NSInteger)index
{
    id superData = _dataArray[index];
    if ([superData isKindOfClass:NSArray.class]) {
        return ((NSArray *)superData).count;
    }
    return 0;
}

- (WBSpringBoardCell *)springBoard:(WBSpringBoard *)springBoard subCellForItemAtIndex:(NSInteger)index withSuperIndex:(NSInteger)superIndex;
{
    WBSpringBoardCell *cell = nil;

    id superData = _dataArray[superIndex];
    if ([superData isKindOfClass:NSArray.class]) {
        NSArray *dataArr = superData;
        id data = dataArr[index];
        
        if ([data isKindOfClass:NSString.class]) {
            WBCustomerCell *customerCell = [[WBCustomerCell alloc] init];
            customerCell.backgroundColor = [UIColor lightGrayColor];
            customerCell.label.text = (NSString *)data;
            
            cell = customerCell;
        } else if ([data isKindOfClass:NSArray.class]) {
            WBCustomerCombinedCell *customerCombinedCell = [[WBCustomerCombinedCell alloc] init];
            customerCombinedCell.backgroundColor = [UIColor darkGrayColor];
            customerCombinedCell.label.text = [((NSArray *)data) componentsJoinedByString:@","];
            
            cell = customerCombinedCell;
        }
    }
    
    return cell;
}

- (void)springBoard:(WBSpringBoard *)springBoard moveItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    NSString *data = _dataArray[sourceIndex];
    [_dataArray removeObjectAtIndex:sourceIndex];
    [_dataArray insertObject:data atIndex:destinationIndex];
    
    NSLog(@"%@", _dataArray);
}

- (void)springBoard:(WBSpringBoard *)springBoard combineItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    NSString *sourceData = _dataArray[sourceIndex];
    id destinationData = _dataArray[destinationIndex];
    
    NSMutableArray *combinedData = [@[sourceData] mutableCopy];
    if ([destinationData isKindOfClass:[NSString class]]) {
        [combinedData addObject:destinationData];
    } else if ([destinationData isKindOfClass:[NSArray class]]) {
        [combinedData addObjectsFromArray:destinationData];
    }
    
    [_dataArray replaceObjectAtIndex:destinationIndex withObject:combinedData];
    [_dataArray removeObjectAtIndex:sourceIndex];
    
    NSLog(@"%@", _dataArray);
}

- (void)springBoard:(WBSpringBoard *)springBoard moveSubItemAtIndex:(NSInteger)sourceIndex toSubIndex:(NSInteger)destinationIndex withSuperIndex:(NSInteger)superIndex
{
    NSMutableArray *superDataArray = _dataArray[superIndex];
    
    NSString *data = superDataArray[sourceIndex];
    [superDataArray removeObjectAtIndex:sourceIndex];
    [superDataArray insertObject:data atIndex:destinationIndex];
    
    _dataArray[superIndex] = superDataArray;
    
    NSLog(@"%@", _dataArray);
}

- (void)springBoard:(WBSpringBoard *)springBoard moveSubItemAtIndex:(NSInteger)sourceIndex toSuperIndex:(NSInteger)destinationIndex withSuperIndex:(NSInteger)superIndex
{
    
}

@end
