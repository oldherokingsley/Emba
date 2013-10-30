//
//  LoginViewController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-10-31.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "LoginViewController.h"
#import "MainPageViewController.h"
#import "DDMenuController.h"
#import "MenuController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize hostController;

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
    [self initView];
	// Do any additional setup after loading the view.
}
- (void)initView
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(1024 / 2 - 100, 200, 200, 50)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:40]];
    [label setText:@"SEMBA"];
    [self.view addSubview:label];
    
    CGRect imageRect = CGRectMake(1024 / 2 - 200, 768 / 2 - 100, 50, 50);
    CGRect fieldRect = CGRectMake(imageRect.origin.x + 50, imageRect.origin.y, 300, 50);
    UIImageView *accountIV = [[UIImageView alloc]initWithFrame:imageRect];
    
    imageRect.origin.y += 50;
    UIImageView *passwordIV = [[UIImageView alloc]initWithFrame:imageRect];;
    
    UITextField *accountTF = [[UITextField alloc]initWithFrame:fieldRect];
    [accountTF setPlaceholder:@"账号"];
    [self.view addSubview:accountTF];
    
    fieldRect.origin.y += 50;
    UITextField *passwordTF = [[UITextField alloc]initWithFrame:fieldRect];
    [passwordTF setPlaceholder:@"密码"];
    [self.view addSubview:passwordTF];
    
    CGRect boxRect = CGRectMake(imageRect.origin.x + 5, imageRect.origin.y + 100, 40, 40);
    UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkBox setFrame:boxRect];
    [checkBox addTarget:self action:@selector(checkBoxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkBox];
    
    UIButton *loginButton = [[UIButton alloc]initWithFrame:CGRectMake(1024 / 2 - 200, 500, 400, 70)];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
}
- (void)checkBoxClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    if (button.selected) {
        NSLog(@"selected");
    } else{
        NSLog(@"no selected");
    }
}

- (void)loginAction:(id)sender
{
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
