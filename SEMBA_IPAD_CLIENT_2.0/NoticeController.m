//
//  NoticeController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-31.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "NoticeController.h"

@interface NoticeController ()

@end

@implementation NoticeController
@synthesize search;
@synthesize noticeTableView;

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
    search = [[UITextField alloc] initWithFrame:CGRectMake(0, 50, 100, 50)];
    search.backgroundColor = [UIColor blackColor];
    [self.view addSubview:search];
    
    noticeTableView = [[NoticeTableView alloc] initWithFrame:CGRectMake(0, search.frame.origin.y + search.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - search.frame.origin.y - search.frame.size.height)];
    [self.view addSubview:noticeTableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
