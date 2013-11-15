//
//  MenuController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-29.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "MenuController.h"
#import "DDMenuController.h"
#import "AppDelegate.h"
#import "EvaluateController.h"
#import "ScheduleController.h"
#import "MainPageViewController.h"
#import "NoticeController.h"
#import "RegisterController.h"
#import "RegisterContentController.h"

#define kMenuTextColor [UIColor whiteColor]

@interface MenuController ()
{
    NSMutableArray *titleArray;
    NSInteger *currentRow;
}

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
        titleArray = [[NSMutableArray alloc] initWithObjects:@"课程中心", @"课件", @"评教", @"课程表", @"通知中心", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    currentRow = 0;
    
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
    list.delegate = self;
    list.dataSource = self;
    [list setScrollEnabled:NO];
    [self.view addSubview:list];
    
    registerBtn = [[UIButton alloc] init];
    registerBtn.frame = CGRectMake(60, 500, 100, 100);
    registerBtn.backgroundColor = [UIColor blackColor];
    [registerBtn addTarget:self action:@selector(registerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
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

-(IBAction)registerBtnPressed:(id)sender
{
    RegisterController *popController = [RegisterController sharedRegisterController];
    
    //[popController presentWithContentController:contentController animated:YES];

    
    [self presentViewController:popController animated:YES completion:nil];
}

#pragma Mark - tableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"A cell for row %d", indexPath.row);
    static NSString *contentIdentifier = @"Cell";
    
    MenuCell *cell =[list dequeueReusableCellWithIdentifier:contentIdentifier];
    
    if(cell == nil){
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentIdentifier];
    }
    
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDMenuController *hostController = (DDMenuController*)((AppDelegate*)[[UIApplication sharedApplication] delegate]).hostController;
    if(currentRow == (NSInteger *)indexPath.row){
        [list deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if(indexPath.row == 1 || indexPath.row == 0){
        MainPageViewController *controller = [[MainPageViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.title = [titleArray objectAtIndex:indexPath.row];
        [hostController setRootController:navController animated:YES];
    }else if(indexPath.row == 2){
        EvaluateController *controller = [[EvaluateController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.title = [titleArray objectAtIndex:indexPath.row];
        [hostController setRootController:navController animated:YES];
    }else if(indexPath.row == 3){
        ScheduleController *controller = [[ScheduleController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.title = [titleArray objectAtIndex:indexPath.row];
        [hostController setRootController:navController animated:YES];
    }else if(indexPath.row == 4){
        NoticeController *controller = [[NoticeController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.title = [titleArray objectAtIndex:indexPath.row];
        [hostController setRootController:navController animated:YES];
    }
    
    currentRow = (NSInteger*)indexPath.row;
    [list deselectRowAtIndexPath:indexPath animated:YES];
}

@end
