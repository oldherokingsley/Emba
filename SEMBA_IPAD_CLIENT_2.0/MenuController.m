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
#import "SetUpView.h"


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
@synthesize registerLabel;
@synthesize backgroundImg;
@synthesize hostController;
@synthesize noticeView;
@synthesize blurView;
@synthesize setupView;

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
//    hostController = (DDMenuController*)((AppDelegate*)[[UIApplication sharedApplication] delegate]).hostController;
    
    currentRow = 0;
    
    float originY = 19.5;
    float menuWidth = 238;
    
    //Background Image
    CGRect backgroundFrame = CGRectMake(0, originY, menuWidth, self.view.frame.size.width - originY);
    backgroundImg = [[UIImageView alloc] init];
    backgroundImg.frame = backgroundFrame;
    [self.view addSubview:backgroundImg];
    
    //headImg
    CGRect headFrame = CGRectMake(53.5, 50, 134, 144);
    headImg = [[UIImageView alloc] init];
    headImg.frame = headFrame;
    headImg.backgroundColor = [UIColor blackColor];
    [self.view addSubview:headImg];
    
    //UserNameLabel
    CGRect nameFrame = CGRectMake(0, 200, menuWidth, 35);
    nameLabel = [[UILabel alloc] init];
    nameLabel.frame = nameFrame;
    nameLabel.text = @"李开花";
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"Helti SC" size:24.0f];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    
    //Menu TableView
    CGRect listFrame = CGRectMake(0, 233.5, menuWidth, 210);
    list = [[UITableView alloc] init];
    list.frame = listFrame;
    list.backgroundColor = [UIColor clearColor];
    list.delegate = self;
    list.dataSource = self;
    [list setScrollEnabled:NO];
    [self.view addSubview:list];
    
    //RegisterButton
    CGRect registerFrame = CGRectMake(54, listFrame.origin.y + listFrame.size.height + 63.5, 104, 96);
    registerBtn = [[UIButton alloc] init];
    registerBtn.frame = registerFrame;
    registerBtn.backgroundColor = [UIColor clearColor];
    [registerBtn addTarget:self action:@selector(registerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    //RegisterLabel
    CGRect registerLabelFrame = CGRectMake(0, registerFrame.origin.y + registerFrame.size.height + 10, menuWidth, 40);
    registerLabel = [[UILabel alloc] init];
    registerLabel.frame = registerLabelFrame;
    registerLabel.text = @"签到";
    registerLabel.textColor = [UIColor whiteColor];
    registerLabel.backgroundColor = [UIColor clearColor];
    registerLabel.font = [UIFont fontWithName:@"Helti SC" size:18.0f];
    registerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:registerLabel];
    
    //Help Button
    CGRect helpFrame = CGRectMake(0, 0, 0, 0);
    helpBtn = [[UIButton alloc] init];
    helpBtn.frame = helpFrame;
    helpBtn.backgroundColor = [UIColor blackColor];
    //[self.view addSubview:helpBtn];
    
    //setting Button
    CGRect settingFrame = CGRectMake(200, listFrame.origin.y + listFrame.size.height + 270, 26, 26);
    settingBtn = [[UIButton alloc] init];
    settingBtn.frame = settingFrame;
    settingBtn.backgroundColor = [UIColor clearColor];
    [settingBtn addTarget:self action:@selector(showSetupWindow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    
    [self setImageAndBackground];
    
    //the view contain the noticeView
    noticeView = [[UIView alloc] initWithFrame:CGRectMake(menuWidth, 0, 1024- menuWidth, 768)];
    NoticeController *controller = [[NoticeController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] init];
    navController.view.frame = CGRectMake(0, 0, 1024-250, 60);
    
    [noticeView addSubview:navController.view];
    [noticeView addSubview:controller.view];
    [noticeView setAlpha:0];
    [noticeView setHidden:YES];
    [hostController.view addSubview:noticeView];
    
    blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [blurView setBackgroundColor:[UIColor blackColor]];
    [blurView setAlpha:0.0f];
    [blurView setHidden:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSelector:)];
    [blurView addGestureRecognizer:tapGesture];
    [hostController.view addSubview:blurView];

    setupView = [[SetUpView alloc]initWithDefault:hostController];
    setupView.delegate = self;
    setupView.alpha = 0.0f;
    [hostController.view addSubview:setupView];
}
- (void)showSetupWindow{
    [hostController.tap setEnabled:NO];
    [self showBlur];
    [setupView showSetupView];
}

- (void)tapSelector:(UITapGestureRecognizer *)gesture{
    [setupView hideSetupView];
    [self hideBlur];
    [hostController.tap setEnabled:YES];
}

- (void)showBlur{
    [blurView setHidden:NO];
    [UIView animateWithDuration:0.5f animations:^{
        [blurView setAlpha:0.5f];
    } completion:^(BOOL finished){
        
    }];
}
- (void)hideBlur{
    [UIView animateWithDuration:0.5f animations:^{
        [blurView setAlpha:0.0f];
    } completion:^(BOOL finished){
        [blurView setHidden:YES];
    }];
}
#pragma SetUpViewDelegate mark
- (void)closeSetUpView{
    [setupView hideSetupView];
    [self hideBlur];
    [hostController.tap setEnabled:YES];
}
- (void)logoutAccount{
    [setupView hideSetupView];
    [self hideBlur];
    [hostController.tap setEnabled:YES];
    [hostController dismissViewControllerAnimated:YES completion:nil];
}
- (void)setImageAndBackground
{
    [backgroundImg setImage:[UIImage imageNamed:@"news center-menu.png"]];
    
    [headImg setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"news center-circle on the menu.png"]]];
    
    [registerBtn setImage:[UIImage imageNamed:@"news center-sign.png"] forState:UIControlStateNormal];
    
    [settingBtn setImage:[UIImage imageNamed:@"news center-setting.png"] forState:UIControlStateNormal];
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
    //hostController.rootViewController.view.userInteractionEnabled = YES;
    
    if(currentRow == (NSInteger *)indexPath.row){
        [list deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if(indexPath.row == 1 || indexPath.row == 0){
        MainPageViewController *controller = [[MainPageViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.title = [titleArray objectAtIndex:indexPath.row];
        [hostController setRootController:navController animated:YES];
        
        if(noticeView.isHidden == NO){
            noticeView.alpha = 0.0;
            [noticeView setHidden:YES];
        }
        /*
        if(hostController.view didAddSubview:noticeView){
            [noticeView remo]
        }*/
    }else if(indexPath.row == 2){
        EvaluateController *controller = [[EvaluateController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.title = [titleArray objectAtIndex:indexPath.row];
        [hostController setRootController:navController animated:YES];
        
        if(noticeView.isHidden == NO){
            noticeView.alpha = 0.0;
            [noticeView setHidden:YES];
        }
        
    }else if(indexPath.row == 3){
        ScheduleController *controller = [[ScheduleController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.title = [titleArray objectAtIndex:indexPath.row];
        [hostController setRootController:navController animated:YES];
        

        if(noticeView.isHidden == NO){
            noticeView.alpha = 0.0;
            [noticeView setHidden:YES];
        }
    }else if(indexPath.row == 4){
        [hostController.rootViewController.view setHidden:YES];
        //[hostController setRootController:nil animated:NO];
     //   if(noticeView.hidden == YES){
//[hostController.view addSubview:noticeView];
            [hostController.tap setEnabled:NO];
            [noticeView setHidden:NO];
            [self.view bringSubviewToFront:noticeView];
            [noticeView setFrame:CGRectMake(1024, 0, noticeView.frame.size.width, noticeView.frame.size.height)];
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                noticeView.alpha = 1.0;
                noticeView.frame = CGRectMake(250, 0, noticeView.frame.size.width, noticeView.frame.size.height);
            } completion:^(BOOL finished) {
                
            }];
        
     //   }

    }
    
    currentRow = (NSInteger*)indexPath.row;
    [list deselectRowAtIndexPath:indexPath animated:YES];
}

@end
