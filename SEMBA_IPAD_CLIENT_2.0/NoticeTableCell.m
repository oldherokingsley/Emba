//
//  NoticeTableCell.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-31.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "NoticeTableCell.h"
#define kLineFrame CGRectMake(0, 0, 700, 10)
#define kTitleFrame CGRectMake(0, 0, 50, 30)
#define kDateFrame CGRectMake(0, 30, 100, 10)
#define kContentFrame CGRectMake(10, 50, 700, 16)
#define kRotateButtonFrame CGRectMake(700, 35, 20, 20)

@implementation NoticeTableCell
@synthesize topLine;
@synthesize title;
@synthesize content;
@synthesize date;
@synthesize indexPath;
@synthesize rotateBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"A Cell has initlized");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        topLine = [[UIImageView alloc] init];
        topLine.frame = kLineFrame;
        topLine.backgroundColor = [UIColor blackColor];
        [self addSubview:topLine];
        
        title = [[UILabel alloc] init];
        title.frame = kTitleFrame;
        title.font =[UIFont systemFontOfSize:12.0f];
        title.textColor =[UIColor brownColor];
        [self addSubview:title];
        
        date = [[UILabel alloc] init];
        date.frame = kDateFrame;
        date.font = [UIFont systemFontOfSize:12.0f];
        date.textColor = [UIColor blackColor];
        [self addSubview:date];
        
        content = [[UILabel alloc] init];
        content.frame = kContentFrame;
        content.font = [UIFont systemFontOfSize:12.0f];
        content.textColor = [UIColor blackColor];
        content.lineBreakMode = NSLineBreakByCharWrapping;
        content.numberOfLines = 0;
        content.adjustsFontSizeToFitWidth = NO;
        content.lineBreakMode = NSLineBreakByTruncatingTail;
        content.backgroundColor = [UIColor clearColor];
        [self addSubview:content];
        
        rotateBtn = [[UIButton alloc] init];
        rotateBtn.frame = kRotateButtonFrame;
        [rotateBtn setImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateNormal];
        [rotateBtn setBackgroundColor:[UIColor blackColor]];
        [self addSubview:rotateBtn];
    }
    return self;
}

#pragma mark - behavior

- (void)rotateExpandBtnToExpanded
{
    [UIView beginAnimations:@"rotateDisclosureButt" context:nil];
    [UIView setAnimationDuration:0.2];
    rotateBtn.transform = CGAffineTransformMakeRotation(M_PI*1.5);
    [UIView commitAnimations];
}

- (void)rotateExpandBtnToCollapsed
{
    [UIView beginAnimations:@"rotateDisclosureButt" context:nil];
    [UIView setAnimationDuration:0.2];
    rotateBtn.transform = CGAffineTransformMakeRotation(M_PI*2.5);
    [UIView commitAnimations];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

@end

