//
//  ScheduleController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-30.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "ScheduleController.h"
#import "RightCell.h"
#import "LeftCell.h"
#import "CellData.h"

#define kCellSize CGSizeMake(600, 200)
#define kDistanceOfCells 200
#define kOriginXOfRightCells 450
#define kOriginYofTopCell 100.0f
#define kYearLabelSize CGSizeMake(200, 100)

@interface ScheduleController ()

@end

@implementation ScheduleController
{
    float originY;
    int cellCount;
}

@synthesize scrollView;
@synthesize dataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    cellCount = 10;

    
    dataArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < cellCount; ++i){
        CellData *data = [[CellData alloc] init];
        [dataArray addObject:data];
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                self.navigationController.navigationBar.frame.size.height,
                                                                self.view.frame.size.height,
                                                                self.view.frame.size.width)];

    [self.view addSubview:scrollView];
    
    for(int i = 0; i < cellCount; ++i){
        
        originY = i * kDistanceOfCells + kOriginYofTopCell;
        
        //Add a label of year to view
        if(0){
            UILabel *year = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, kYearLabelSize.width, kYearLabelSize.height)];
            [self.scrollView addSubview:year];
            originY += year.frame.size.height;
        }
        
        if(i % 2 == 0){
            
            RightCell *cell1 = [[RightCell alloc] initWithFrame:CGRectMake(kOriginXOfRightCells, originY, kCellSize.width, kCellSize.height)];
            cell1.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:cell1];
            [cell1 setData:[dataArray objectAtIndex:i]];
            
        }else {
            
            LeftCell *cell2 = [[LeftCell alloc] initWithFrame:CGRectMake(0, originY, kCellSize.width, kCellSize.height)];
            cell2.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:cell2];
            [cell2 setData:[dataArray objectAtIndex:i]];
        }
    }
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, (cellCount / 2 + 1) * 500)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
