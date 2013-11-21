//
//  RightCell.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-11-11.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "RightCell.h"
#define kMonthBgRect CGRectMake(0, 75, 50, 50)
#define kMonthRect CGRectMake(0, 80, 50, 30)
#define kContentBgRect CGRectMake(100, 20, 300, 160)
#define kNameRect CGRectMake(130, 30, 60, 30)
#define kTeacherRect CGRectMake(200, 30, 80, 30)
#define kDateRect CGRectMake(130, 70, 200, 30)
#define kPlaceRect CGRectMake(130, 110, 200, 30)
#define kTimeRect CGRectMake(130, 150, 200, 70)

@implementation RightCell
@synthesize month;
@synthesize monthBg;
@synthesize name;
@synthesize teacher;
@synthesize date;
@synthesize place;
@synthesize time;
@synthesize contentBg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        monthBg = [[UIImageView alloc] initWithFrame:kMonthBgRect];
        monthBg.backgroundColor = [UIColor blackColor];
        [self addSubview:monthBg];
        
        contentBg = [[UIImageView alloc] initWithFrame:kContentBgRect];
        contentBg.backgroundColor = [UIColor blackColor];
        [self addSubview:contentBg];
        
        month = [[UILabel alloc] initWithFrame:kMonthRect];
        month.backgroundColor = [UIColor grayColor];
        month.text = @"aaa";
        [self addSubview:month];
        
        name = [[UILabel alloc] initWithFrame:kNameRect];
        name.text = @"aaaa";
        name.backgroundColor = [UIColor grayColor];
        [self addSubview:name];
        
        teacher = [[UILabel alloc] initWithFrame:kTeacherRect];
        teacher.text = @"bbbbbb";
        teacher.backgroundColor = [UIColor grayColor];
        [self addSubview:teacher];
        
        date = [[UILabel alloc] initWithFrame:kDateRect];
        date.text = @"cccccccccc";
        date.backgroundColor = [UIColor grayColor];
        [self addSubview:date];
        
        place = [[UILabel alloc] initWithFrame:kPlaceRect];
        place.text = @"dddddddd";
        place.backgroundColor = [UIColor grayColor];
        [self addSubview:place];
        
        time = [[UILabel alloc] initWithFrame:kTimeRect];
        time.backgroundColor = [UIColor grayColor];
        time.text = @"eeeeeeeeeee";
        [self addSubview:time];
    
    }
    return self;
}

- (void)setData:(CellData *)data
{
    self.month.text = data.month;
    self.name.text = data.name;
    self.teacher.text = data.teacher;
    self.date.text = data.date;
    self.place.text = data.place;
    self.time.text = data.time;
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
