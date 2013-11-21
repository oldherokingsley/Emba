//
//  MenuController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-29.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCell.h"


@class DDMenuController;

@protocol menuControllerDelegate;

@interface MenuController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UIImageView *backgroundImg;
@property (nonatomic, retain) UIImageView *headImg;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIButton *registerBtn;
@property (nonatomic, retain) UIButton *helpBtn;
@property (nonatomic, retain) UIButton *settingBtn;
@property (nonatomic, retain) UILabel *registerLabel;
@property (nonatomic, retain) DDMenuController *hostController;
@property (nonatomic, retain) UIView *noticeView;
@property (nonatomic, assign) id <menuControllerDelegate> delegate;

- (IBAction)registerBtnPressed:(id)sender;

@end

@protocol menuControllerDelegate

- (void)disableTap;

@end
