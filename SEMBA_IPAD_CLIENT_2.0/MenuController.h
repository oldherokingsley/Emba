//
//  MenuController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-29.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCell.h"

@interface MenuController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UIImageView *headImg;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIButton *registerBtn;
@property (nonatomic, retain) UIButton *helpBtn;
@property (nonatomic, retain) UIButton *settingBtn;

- (IBAction)registerBtnPressed:(id)sender;

@end
