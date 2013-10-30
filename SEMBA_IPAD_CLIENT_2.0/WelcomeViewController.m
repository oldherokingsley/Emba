//
//  ViewController.m
//  SYSBS_EMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-21.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "WelcomeViewController.h"
#import "MainPageViewController.h"
#import "DDMenuController.h"
#import "MenuController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController
@synthesize welBGImage;
@synthesize hostController;

#define WAITING_TIME 1

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
	// Do any additional setup after loading the view, typically from a nib.
    
    welBGImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    UIImage *image = [UIImage imageNamed:@"welcome.jpg"];
    [welBGImage setImage:image];
    [self.view addSubview:welBGImage];
    
    NSThread *waitThread = [[NSThread alloc]initWithTarget:self selector:@selector(waitingAction) object:nil];
    [waitThread start];
    
    NSThread *downLoadThread = [[NSThread alloc] initWithTarget:self selector:@selector(downLoadImageAction) object:nil];
    [downLoadThread start];
}

- (void)downLoadImageAction
{
    //在这里下载图片
    [self performSelectorOnMainThread:@selector(loadFinished) withObject:NULL waitUntilDone:YES];
}

- (void)loadFinished
{
    
}

- (void)waitingAction
{
    [NSThread sleepForTimeInterval:WAITING_TIME];
    [self performSelectorOnMainThread:@selector(jumpToMainPage) withObject:NULL waitUntilDone:YES];
    
}

- (void)jumpToMainPage
{
//    [self performSegueWithIdentifier:@"jumpFromWelToMainID" sender:nil];
    MainPageViewController *mainController = [[MainPageViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    hostController = [[DDMenuController alloc] initWithRootViewController:navController];
    MenuController *menuController = [[MenuController alloc] init];
    hostController.leftViewController = menuController;
    
    
    [self presentViewController:hostController animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
