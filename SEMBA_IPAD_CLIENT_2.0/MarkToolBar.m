//
//  MarkToolBar.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-7.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "MarkToolBar.h"

#define BUTTON_X 5.0f
#define BUTTON_Y 20.0f
#define BUTTON_SPACE 12.0f
#define BUTTON_HEIGHT 44.0f

#define BUTTON_WIDTH 56.0f

@implementation MarkToolBar
@synthesize cancelButton;
@synthesize editButton;
@synthesize finishButton;
@synthesize backButton;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bar_bg"]];
        [self setBackgroundColor:background];
        CGFloat leftButtonX = BUTTON_X;
        
        backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        backButton.frame = CGRectMake(leftButtonX, BUTTON_Y, 66, BUTTON_HEIGHT);
        [backButton setTintColor:[UIColor redColor]];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [backButton setImage:[UIImage imageNamed:@"bookmark_back"] forState:UIControlStateNormal];
//        [backButton setImageEdgeInsets:UIEdgeInsetsMake(4, 0, 4, 0)];
        [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [cancelButton setTitle:@"放弃" forState:UIControlStateNormal];
        [cancelButton setTintColor:[UIColor redColor]];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setHidden:YES];
        [self addSubview:cancelButton];
        
        
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        
        CGFloat rightButtonX = 1024 - BUTTON_X - BUTTON_WIDTH;
        
        editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        editButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [editButton setTintColor:[UIColor redColor]];
        [editButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:editButton];
        
        finishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        finishButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [finishButton setTintColor:[UIColor redColor]];
        [finishButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [finishButton addTarget:self action:@selector(finishAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:finishButton];
        [finishButton setHidden:YES];
        rightButtonX -= (BUTTON_WIDTH + BUTTON_SPACE);
        
    }
    return self;
}

- (void)backAction:(UIButton *)button
{
    [delegate tappedInMarkToolBar:self back:button];
}
-(void)editAction:(UIButton *)button
{
    [delegate tappedInMarkToolBar:self edit:button];
}
-(void)cancelAction:(UIButton *)button
{
    [delegate tappedInMarkToolBar:self cancel:button];
}
-(void)finishAction:(UIButton *)button
{
    [delegate tappedInMarkToolBar:self finish:button];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
