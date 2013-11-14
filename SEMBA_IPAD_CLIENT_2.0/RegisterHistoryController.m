//
//  RegisterHistoryController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-11-6.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "RegisterHistoryController.h"
#define tableViewRect CGRectMake(0, 0, 300, 250)

@interface RegisterHistoryController ()

@end

@implementation RegisterHistoryController
{
    int historyCount;
}
@synthesize historyList;

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
    [self.navigationItem setTitle:@"签到历史"];
    
    historyList = [[UITableView alloc] initWithFrame:tableViewRect];
    [self.view addSubview:historyList];
    [self.historyList setRowHeight:30.0f];
    self.historyList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [historyList setEditing:NO];
    [historyList setAllowsSelection:NO];
    
    historyList.delegate = self;
    historyList.dataSource = self;
    
    historyCount = 5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return historyCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *contentIdentifier = @"historyListCell";
    
    UITableViewCell *cell = [historyList dequeueReusableCellWithIdentifier:contentIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:contentIdentifier];
    }
    
    cell.textLabel.text = @"你在XXXXX签到了";
    
    return cell;
}

@end

