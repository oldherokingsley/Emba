//
//  LoginViewController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-11.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "LoginViewController.h"
#import "MainPageViewController.h"
#import "MenuController.h"
#import "DDMenuController.h"
#import "Dao.h"
#import "SysbsModel.h"

BOOL keyBoardIsAppear;
BOOL shouldLogin;

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize passwordTF;
@synthesize loginButton;
@synthesize accountTF;
@synthesize loginView;

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
    // Do any additional setup after loading the view from its nib.
    accountTF.delegate = self;
    passwordTF.delegate = self;
    passwordTF.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender {
    NSString *accountText = accountTF.text;
    NSString *passwordText = passwordTF.text;
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:accountText,@"account",passwordText,@"password", nil];
    NSThread *loginThread = [[NSThread alloc]initWithTarget:self selector:@selector(loginSelector:) object:dict];
    [loginThread start];
}
- (void)loginSelector:(NSDictionary *)loginInfo{
    NSString *accountText = (NSString *)[loginInfo objectForKey:@"account"];
    NSString *passwordText = (NSString *)[loginInfo objectForKey:@"password"];
    
    if ([accountText length] == 0 || [passwordText length] == 0) {
        UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:@"出错啦"
                                                          message:@"手机号或密码不能为空，请输入！"
                                                         delegate:nil
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
        //            alertView.delegate = self;
        [alertView show];
        
        
        [loginButton setEnabled:YES];
        return;
    }
    Dao *dao = [Dao sharedDao];
    int loginResult = 1;//[dao requestForLogin:accountText password:passwordText];
    if (loginResult == 1) {
//        [self jumpToMainPage];
        NSLog(@"login success");
        [self performSelectorOnMainThread:@selector(jumpToMainPage) withObject:nil waitUntilDone:NO];
    } else if (loginResult == 0){
        NSLog(@"网络连接失败！");
    } else if (loginResult == -1){
        NSLog(@"密码输入错误！");
    } else if (loginResult == -2){
        NSLog(@"用户不存在！");
    }
    
}
- (void)jumpToMainPage{
    MainPageViewController *mainController = [[MainPageViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    DDMenuController *hostController;
    hostController = [[DDMenuController alloc] initWithRootViewController:navController];
    MenuController *menuController = [[MenuController alloc] init];
    hostController.leftViewController = menuController;
    
    
    [self presentViewController:hostController animated:YES completion:nil];
    
}

#pragma Mark UITextFieldDelegate
// 下面两个方法是为了防止TextView让键盘挡住的方法
/*
 开始编辑UITextView的方法
 */
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (keyBoardIsAppear) {
        return;
    }
    NSLog(@"yes");
    keyBoardIsAppear = YES;
    
    CGRect curFrame = self.loginView.frame;
    [UIView animateWithDuration:0.3f animations:^{
        self.loginView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y - 200, curFrame.size.width, curFrame.size.height);
    }];
}

/**
 结束编辑UITextView的方法，让原来的界面还原高度
 */
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if (!keyBoardIsAppear) {
        if (shouldLogin) {
//            [self disappearAnimBegin];
        }
        return;
    }
    
    NSLog(@"no");
    
    
    
    CGRect curFrame=self.loginView.frame;
    [UIView beginAnimations:@"drogDownKeyBoard" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.loginView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y + 200, curFrame.size.width, curFrame.size.height);
    if (shouldLogin) {
        NSLog(@"ddddddddddddd");
//        [UIView setAnimationDidStopSelector:@selector(disappearAnimBegin)];
    }
    
    [UIView commitAnimations];
    //    [UIView animateWithDuration:0.3f animations:^{
    //        self.view.frame = CGRectMake(curFrame.origin.x + 200, curFrame.origin.y, curFrame.size.width, curFrame.size.height);
    
    //    }];
    //self.view移回原位置
    
    keyBoardIsAppear = NO;
    shouldLogin = NO;
    //    if (shouldLogin) {
    
    //    }
}

@end
