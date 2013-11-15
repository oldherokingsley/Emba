//
//  NoticeTableView.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-31.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeTableView : UITableView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *contentArray;
@property (nonatomic, strong) NSMutableArray *cellArray;
@property (nonatomic, strong) NSMutableArray *dateArray;

@end
