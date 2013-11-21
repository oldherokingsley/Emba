//
//  myCourseBtn.h
//  SYSBS_EMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-21.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CourseItem : UIView
@property (nonatomic, strong) UIImageView *courseImg;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *resumeLabel;

-(void)jumpToDetail:(id)sender;
- (id)initWithFrame:(CGRect)frame :(NSDictionary *)courseDict;
@end
