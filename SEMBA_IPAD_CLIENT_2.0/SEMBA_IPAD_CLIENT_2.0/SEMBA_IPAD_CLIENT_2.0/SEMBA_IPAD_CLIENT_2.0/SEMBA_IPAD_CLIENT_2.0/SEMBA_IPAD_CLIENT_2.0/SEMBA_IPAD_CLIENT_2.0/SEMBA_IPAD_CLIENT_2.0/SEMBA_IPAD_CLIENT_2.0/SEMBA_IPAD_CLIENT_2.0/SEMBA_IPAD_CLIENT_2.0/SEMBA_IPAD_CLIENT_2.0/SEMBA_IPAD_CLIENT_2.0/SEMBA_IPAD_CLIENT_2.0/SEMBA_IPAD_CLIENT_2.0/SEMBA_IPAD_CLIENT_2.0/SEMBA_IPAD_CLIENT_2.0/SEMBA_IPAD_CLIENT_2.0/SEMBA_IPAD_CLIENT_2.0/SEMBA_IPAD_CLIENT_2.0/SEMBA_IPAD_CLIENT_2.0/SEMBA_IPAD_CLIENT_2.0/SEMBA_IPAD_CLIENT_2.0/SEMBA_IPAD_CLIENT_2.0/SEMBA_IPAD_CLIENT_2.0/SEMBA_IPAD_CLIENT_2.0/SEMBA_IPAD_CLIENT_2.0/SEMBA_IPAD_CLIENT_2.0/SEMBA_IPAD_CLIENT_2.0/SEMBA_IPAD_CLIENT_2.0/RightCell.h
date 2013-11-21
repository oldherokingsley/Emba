//
//  RightCell.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-11-11.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellData.h"

@interface RightCell : UIView
@property (nonatomic, strong) UILabel *month;
@property (nonatomic, strong) UIImageView *monthBg;
@property (nonatomic, strong) UIImageView *contentBg;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *teacher;
@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UILabel *place;
@property (nonatomic, strong) UILabel *time;

- (void)setData:(CellData *)data;

@end
