//
//  ChangePswViewController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-21.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "ChangePswViewController.h"
#define START_X     41.0f
#define START_Y     29.0f
#define LABEL_WIDTH 200.0f
#define LABEL_HEIGHT   20.0f
#define TF_WIDTH    314.0f
#define TF_HEIGHT   39.0f
#define ITEM_SPACE  100.0f
#define INSIDE_SPACE    11.0f
#define BUTTON_X    155.0f
#define BUTTON_Y    359.0f
#define BUTTON_WIDTH   106.0f
#define BUTTON_HEIGHT   38.0f

NSString *TFImageName = @"setting_text_field";
NSString *buttonImageName = @"setting_button";
@interface ChangePswViewController ()
{
    UIView *parentView;
}
@end

@implementation ChangePswViewController

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
    parentView = self.navigationController.view.superview;
    [self initViews];
	// Do any additional setup after loading the view.
}

- (void)initViews{
    CGFloat top_y = START_Y;
    
    UIFont *textFont = [UIFont systemFontOfSize:18.0f];
    UIColor *textColor = [UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    
    UILabel *originalPswLabel = [[UILabel alloc]initWithFrame:CGRectMake(START_X, top_y, LABEL_WIDTH, LABEL_HEIGHT)];
    [originalPswLabel setText:@"请输入原密码"];
    [originalPswLabel setBackgroundColor:[UIColor clearColor]];
    [originalPswLabel setTextColor:textColor];
    [originalPswLabel setFont:textFont];
    [originalPswLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:originalPswLabel];
//    top_y += (INSIDE_SPACE + LABEL_HEIGHT);
    UITextField *originalPswTF = [[UITextField alloc]initWithFrame:CGRectMake(START_X, top_y + (INSIDE_SPACE + LABEL_HEIGHT), TF_WIDTH, TF_HEIGHT)];
    [originalPswTF setSecureTextEntry:YES];
    [originalPswTF setBackground:[UIImage imageNamed:TFImageName]];
    originalPswTF.delegate = self;
    [self.view addSubview:originalPswTF];
    top_y += ITEM_SPACE;
    
    UILabel *newFirstPswLabel = [[UILabel alloc]initWithFrame:CGRectMake(START_X, top_y, LABEL_WIDTH, LABEL_HEIGHT)];
    [newFirstPswLabel setText:@"请输入新密码"];
    [newFirstPswLabel setBackgroundColor:[UIColor clearColor]];
    [newFirstPswLabel setTextColor:textColor];
    [newFirstPswLabel setFont:textFont];
    [newFirstPswLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:newFirstPswLabel];
//    top_y += (INSIDE_SPACE + LABEL_HEIGHT);
    UITextField *newFirstPswTF = [[UITextField alloc]initWithFrame:CGRectMake(START_X, top_y + (INSIDE_SPACE + LABEL_HEIGHT), TF_WIDTH, TF_HEIGHT)];
    [newFirstPswTF setSecureTextEntry:YES];
    [newFirstPswTF setBackground:[UIImage imageNamed:TFImageName]];
    newFirstPswTF.delegate = self;
    [self.view addSubview:newFirstPswTF];
    top_y += ITEM_SPACE;
    
    UILabel *newSecondPswLabel = [[UILabel alloc]initWithFrame:CGRectMake(START_X, top_y, LABEL_WIDTH, LABEL_HEIGHT)];
    [newSecondPswLabel setText:@"请输入新密码"];
    [newSecondPswLabel setBackgroundColor:[UIColor clearColor]];
    [newSecondPswLabel setTextColor:textColor];
    [newSecondPswLabel setFont:textFont];
    [newSecondPswLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:newSecondPswLabel];
//    top_y += (INSIDE_SPACE + LABEL_HEIGHT);
    UITextField *newSecondPswTF = [[UITextField alloc]initWithFrame:CGRectMake(START_X, top_y + (INSIDE_SPACE + LABEL_HEIGHT), TF_WIDTH, TF_HEIGHT)];
    [newSecondPswTF setSecureTextEntry:YES];
    [newSecondPswTF setBackground:[UIImage imageNamed:TFImageName]];
    newSecondPswTF.delegate = self;
    [self.view addSubview:newSecondPswTF];
    top_y += ITEM_SPACE;
    
    UIButton *sureButton = [[UIButton alloc]initWithFrame:CGRectMake(BUTTON_X, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [sureButton setBackgroundImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
    [sureButton setTitle:@"确认" forState:UIControlStateNormal];
    [sureButton setTintColor:[UIColor whiteColor]];
    [sureButton.titleLabel setFont:textFont];
    [self.view addSubview:sureButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark UITextFieldDelegate
// 下面两个方法是为了防止TextView让键盘挡住的方法
/*
 开始编辑UITextView的方法
 */
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect curFrame = parentView.frame;
    [UIView animateWithDuration:0.3f animations:^{
        parentView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y - 200, curFrame.size.width, curFrame.size.height);
    }];
}

/**
 结束编辑UITextView的方法，让原来的界面还原高度
 */
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    
    CGRect curFrame = parentView.frame;
    [UIView beginAnimations:@"drogDownKeyBoard" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    parentView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y + 200, curFrame.size.width, curFrame.size.height);
    [UIView commitAnimations];
}



@end
