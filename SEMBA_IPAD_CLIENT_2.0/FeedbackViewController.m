//
//  FeedbackViewController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-22.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "FeedbackViewController.h"

#define START_X     26.0f
#define LABEL_Y     40.0f
#define LABEL_WIDTH 345.0f
#define LABEL_HEIGHT 70.0f
#define TEXTVIEW_Y      133.0f
#define TEXTVIEW_WIDTH  367.0f
#define TEXTVIEW_HEIGHT 176.0f
#define BUTTON_X    155.0f
#define BUTTON_Y    362.0f
#define BUTTON_WIDTH   106.0f
#define BUTTON_HEIGHT   38.0f

NSString *TVImageName = @"setting_text_field_big";
NSString *buttonImageName2 = @"setting_button";
@interface FeedbackViewController (){
    UIView *parentView;
}

@end

@implementation FeedbackViewController

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
    parentView = self.navigationController.view.superview;
    [self initViews];
}
- (void)initViews{
    
    UIFont *textFont = [UIFont systemFontOfSize:18.0f];
    UIColor *textColor = [UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];

    UILabel *decLabel = [[UILabel alloc]initWithFrame:CGRectMake(START_X, LABEL_Y, LABEL_WIDTH, LABEL_HEIGHT)];
    [decLabel setTextColor:textColor];
    [decLabel setFont:textFont];
    [decLabel setText:@"      任何关于产品的建议将有助于我们为您更好的体验。请您把宝贵的意见告诉我们，我们会第一时间处理，谢谢。"];
    [decLabel setNumberOfLines:0];
    [decLabel setBackgroundColor:[UIColor clearColor]];
    [decLabel setLineBreakMode:NSLineBreakByCharWrapping];
    
    [self.view addSubview:decLabel];
    
    UIImageView *TVBgIV = [[UIImageView alloc]initWithFrame:CGRectMake(START_X, TEXTVIEW_Y, TEXTVIEW_WIDTH, TEXTVIEW_HEIGHT)];
    [TVBgIV setImage:[UIImage imageNamed:TVImageName]];
    [self.view addSubview:TVBgIV];
    
    UITextView *contentTV = [[UITextView alloc]initWithFrame:CGRectMake(START_X, TEXTVIEW_Y, TEXTVIEW_WIDTH, TEXTVIEW_HEIGHT)];
    [contentTV setBackgroundColor:[UIColor clearColor]];
//    contentTV seti
    [contentTV setTextColor:textColor];
    [contentTV setFont:textFont];
    contentTV.delegate = self;
    [self.view addSubview: contentTV];
    
    UIButton *sureButton = [[UIButton alloc]initWithFrame:CGRectMake(BUTTON_X, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [sureButton setBackgroundImage:[UIImage imageNamed:buttonImageName2] forState:UIControlStateNormal];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
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
- (void) textViewDidBeginEditing:(UITextView *)textView{
    CGRect curFrame = parentView.frame;
    [UIView animateWithDuration:0.3f animations:^{
        parentView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y - 200, curFrame.size.width, curFrame.size.height);
    }];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    CGRect curFrame = parentView.frame;
    [UIView beginAnimations:@"drogDownKeyBoard" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    parentView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y + 200, curFrame.size.width, curFrame.size.height);
    [UIView commitAnimations];
}
/*
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect curFrame = markEditView.frame;
    [UIView animateWithDuration:0.3f animations:^{
        markEditView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y - 200, curFrame.size.width, curFrame.size.height);
    }];
}
*/
/**
 结束编辑UITextView的方法，让原来的界面还原高度
 */
/*
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    
    CGRect curFrame = markEditView.frame;
    [UIView beginAnimations:@"drogDownKeyBoard" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    markEditView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y + 200, curFrame.size.width, curFrame.size.height);
    [UIView commitAnimations];
}*/



@end
