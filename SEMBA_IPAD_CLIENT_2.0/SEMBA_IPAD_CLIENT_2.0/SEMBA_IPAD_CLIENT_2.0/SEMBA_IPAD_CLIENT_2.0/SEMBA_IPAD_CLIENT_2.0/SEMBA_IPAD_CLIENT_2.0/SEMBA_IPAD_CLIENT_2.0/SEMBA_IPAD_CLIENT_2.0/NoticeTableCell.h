//
//  NoticeTableCell.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-31.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeTableCell : UITableViewCell

@property (nonatomic, retain) UIImageView *topLine;

@property (nonatomic, retain) UILabel *title;

@property (nonatomic, retain) UILabel *content;

@property (nonatomic, retain) UILabel *date;

@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic, retain) UIButton *rotateBtn;

- (void)rotateExpandBtnToExpanded;

- (void)rotateExpandBtnToCollapsed;

@end
