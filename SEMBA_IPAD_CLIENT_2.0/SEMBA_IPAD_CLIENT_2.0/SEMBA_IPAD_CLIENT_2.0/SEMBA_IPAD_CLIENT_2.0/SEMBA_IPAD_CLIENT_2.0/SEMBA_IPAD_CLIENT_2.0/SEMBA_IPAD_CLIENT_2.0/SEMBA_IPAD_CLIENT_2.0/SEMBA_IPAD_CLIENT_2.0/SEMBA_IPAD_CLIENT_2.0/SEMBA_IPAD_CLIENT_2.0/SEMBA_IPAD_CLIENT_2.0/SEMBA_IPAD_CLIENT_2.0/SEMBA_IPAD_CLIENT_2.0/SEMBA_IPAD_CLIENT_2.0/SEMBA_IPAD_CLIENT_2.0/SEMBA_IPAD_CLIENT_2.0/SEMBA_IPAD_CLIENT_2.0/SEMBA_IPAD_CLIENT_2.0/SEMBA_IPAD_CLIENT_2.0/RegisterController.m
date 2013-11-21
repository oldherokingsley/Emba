
//
//  RegisterController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-30.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "RegisterController.h"
#import "RegisterContentController.h"
#import "RegisterHistoryController.h"
#import "Reachability.h"

#define kDefaultMaskColor  [UIColor colorWithWhite:0 alpha:0.5]
#define kDefaultFrameColor [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f]
#define kDefaultFrameSize  CGSizeMake(320 - 66, 460 - 66)
#define kRootKey           @"root"

@interface RegisterController ()
{
    BOOL isExistenceNetwork;
}

@property (nonatomic, retain, readonly) UIControl *maskControl;
@property (nonatomic, retain, readonly) UIView *contentView;
@property (nonatomic, retain, readonly) UINavigationController *navigationController;
@property (nonatomic, retain) UIImageView *shadowView;

- (void)layoutFrameView;

- (void)maskControlDidTouchUpInside:(id)sender;

@end

@implementation RegisterController{
@private
    BOOL _presented;
    UIControl *_maskControl;
    UIView *_contentView;
    UINavigationController *_navController;
    UIViewController *_contentViewController;
}
@synthesize frameSize;

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
    
    [self.view setBackgroundColor:[UIColor clearColor]];
	
	UIView *maskControl = [self maskControl];
	CGSize viewSize = [self.view frame].size;
    NSLog(@"%f----%f", self.view.frame.origin.x, self.view.frame.origin.y);

	[maskControl setFrame:CGRectMake(0, 0,
									 1024, 768)];
    NSLog(@"%f---%f", viewSize.width, viewSize.height);
	[self.view addSubview:maskControl];
    
    UIView *contentView = [self contentView];
	CGRect contentFrame = CGRectMake(100, 100,300,300);
    
	[contentView setFrame:contentFrame];
    [self.view addSubview:contentView];
    
    [self.contentView addSubview:[self navigationController].view];
    
    //Check whether there exist network
    Reachability *r = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]){
        case NotReachable:
            NSLog(@"Can't register because of not existing network.");
            isExistenceNetwork = NO;
            break;
        case ReachableViaWWAN:
            NSLog(@"Can register via 3G.");
            isExistenceNetwork = YES;
            break;
        case ReachableViaWiFi:
            NSLog(@"Can register via WiFi");
            isExistenceNetwork = YES;
            break;
    }
    NSArray *controllers;
    
    if(isExistenceNetwork == NO){
        UIAlertView *noNetAlert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:@"无网络，请检查你的网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [noNetAlert show];
        
        RegisterHistoryController *rootController = [[RegisterHistoryController alloc] init];
        controllers = [NSArray arrayWithObjects:rootController, nil];
    }else {
        
        RegisterContentController *rootController = [[RegisterContentController alloc] init];
        controllers = [NSArray arrayWithObjects:rootController, nil];
    }
    
    [self.navigationController setViewControllers:controllers];
    
    [self.navigationController.view setFrame:CGRectMake(0, 0, contentFrame.size.width, contentFrame.size.height)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView*)contentView {
	if (_contentView == nil) {
		_contentView = [[UIView alloc] init];
		[_contentView setClipsToBounds:YES];
	}
	return _contentView;
}

#pragma Mark - behavior
- (UIControl*)maskControl
{
    if(_maskControl == nil){
        _maskControl = [[UIControl alloc] init];
        [_maskControl setBackgroundColor:kDefaultMaskColor];
        [_maskControl addTarget:self
                         action:@selector(maskControlDidTouchUpInside:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskControl;
}

- (void)maskControlDidTouchUpInside:(id)sender
{
    //[self dismissAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissAnimated:(BOOL)animated
{
    __block RegisterController *me = self;
    [UIView animateWithDuration:(animated ? 0.3 : 0)
                     animations:^(void){
                         [me.view setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             [me.view removeFromSuperview];
                             _presented = NO;
                         }
                     }];
}


#pragma Mark - Singleton

+ (RegisterController*)sharedRegisterController
{
    static RegisterController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RegisterController alloc] init];
    });
    return instance;
}

#pragma Mark - presentViewController

- (void)presentWithContentController:(UIViewController *)contentController animated:(BOOL)animated
{
    if(_presented){
        return;
    }
    _presented = YES;
    
    [self.view setAlpha:0];
    
    if(_contentViewController != contentController){
        [[_contentViewController view] removeFromSuperview];
        _contentViewController = contentController;
        
        NSArray *viewControllers = [NSArray arrayWithObjects:_contentViewController, nil];
        [self.navigationController setViewControllers:viewControllers];
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect appFrame = CGRectMake(0, 0, 1024, 768);
    [self.view setFrame:[window convertRect:appFrame fromWindow:nil]];

    NSLog(@"%f  %f  %f  %f", appFrame.origin.x, appFrame.origin.y, appFrame.size.width, appFrame.size.height);
    [self.parentViewController.view addSubview:[self view]];
    
    [self layoutFrameView];
    
    __block RegisterController *me = self;
    [UIView animateWithDuration:(animated ? 0.3 : 0)
                     animations:^(void){
                         [me.view setAlpha:1.0f];
                     }];
}

- (void)layoutFrameView
{

    // Navigation
	UIView *navView = [self.navigationController view];
	[navView setFrame:CGRectMake(0, 0,
								 300, 50)];
	[self.navigationController.navigationBar setFrame:CGRectMake(0, 0,
																 300, 50)];
}

- (UINavigationController*)navigationController {
	if (_navController == nil) {
		UIViewController *dummy = [[UIViewController alloc] init];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dummy];
		
		// Archive navigation controller for changing navigationbar class
		[navController navigationBar];
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:navController forKey:kRootKey];
		[archiver finishEncoding];
		
		// Unarchive it with changing navigationbar class
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		[unarchiver setClass:[UINavigationBar class]
				forClassName:NSStringFromClass([UINavigationBar class])];
		_navController = [unarchiver decodeObjectForKey:kRootKey];
		

	}
	return _navController;
}

@end
