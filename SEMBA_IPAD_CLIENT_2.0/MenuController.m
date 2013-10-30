//
//  MenuController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-29.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "MenuController.h"
#define kMenuTextColor [UIColor whiteColor]

@interface MenuController ()

@end

@implementation MenuController
@synthesize headImg;
@synthesize list;
@synthesize registerBtn;
@synthesize helpBtn;
@synthesize nameLabel;
@synthesize settingBtn;

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
    
    headImg = [[UIImageView alloc] init];
    headImg.frame = CGRectMake(50, 40, 100, 100);
    headImg.backgroundColor = [UIColor blackColor];
    [self.view addSubview:headImg];
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(60, 150, 70, 30);
    nameLabel.text = @"李开花";
    nameLabel.textColor = kMenuTextColor;
    nameLabel.backgroundColor = [UIColor blackColor];
    nameLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
    [self.view addSubview:nameLabel];
    
    list = [[UITableView alloc] init];
    list.frame = CGRectMake(0, 200, 220, 220);
    list.backgroundColor = [UIColor blackColor];
    [self.view addSubview:list];
    
    registerBtn = [[UIButton alloc] init];
    registerBtn.frame = CGRectMake(60, 500, 100, 100);
    registerBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:registerBtn];
    
    helpBtn = [[UIButton alloc] init];
    helpBtn.frame = CGRectMake(0, 730, 30, 30);
    helpBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:helpBtn];
    
    settingBtn = [[UIButton alloc] init];
    settingBtn.frame = CGRectMake(210, 730, 30, 30);
    settingBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:settingBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
