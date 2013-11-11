//
//  LoginViewController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-11.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *accountTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@end
