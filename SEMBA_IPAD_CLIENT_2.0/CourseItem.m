//
//  myCourseBtn.m
//  SYSBS_EMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-21.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "CourseItem.h"

@implementation CourseItem
@synthesize courseImg;
@synthesize nameLabel;
@synthesize dateLabel;
@synthesize resumeLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame :(NSDictionary *)courseDict{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *courseName = [courseDict objectForKey:@"courseName"];
        NSString *date = [courseDict objectForKey:@"date"];
        NSString *teachName = [courseDict objectForKey:@"teachName"];
        UIImage *courseImage = (UIImage *)[courseDict objectForKey:@"courseImage"];
        
        self.backgroundColor = [UIColor grayColor];
        
        courseImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
        [courseImg setImage:courseImage];
        [self addSubview:courseImg];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
        nameLabel.text = courseName;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont fontWithName:@"Heiti SC" size:20.0];
        nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        nameLabel.numberOfLines = 0;
        [self addSubview:nameLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 5, nameLabel.frame.size.width, 10)];
        dateLabel.text = date;
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
        dateLabel.lineBreakMode = NSLineBreakByCharWrapping;
        dateLabel.numberOfLines = 0;
        [self addSubview:dateLabel];
        
        resumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, dateLabel.frame.origin.y + dateLabel.frame.size.height + 15, nameLabel.frame.size.width, 60)];
        resumeLabel.text = teachName;
        resumeLabel.textColor = [UIColor blackColor];
        resumeLabel.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
        resumeLabel.lineBreakMode = NSLineBreakByCharWrapping;
        resumeLabel.numberOfLines = 0;
        [self addSubview:resumeLabel];
        
    }
    return self;

}

- (void)jumpToDetail:(id)sender
{
    NSLog(@"jumpToDetail");
    
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
