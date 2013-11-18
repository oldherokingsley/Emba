//
//  SearchViewController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-18.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import "ReaderViewController.h"
#import "ASIHTTPRequest.h"
@interface SearchViewController : UIViewController <ReaderViewControllerDelegate,UIScrollViewDelegate,ASIHTTPRequestDelegate>


@property (nonatomic, retain) UIScrollView *coursewareSV;
@property (nonatomic, retain) UIScrollView *courseSV;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *courseOriginArray;
@property (nonatomic, retain) NSMutableArray *coursewareOriginArray;
@property (nonatomic, retain) NSMutableArray *courseDisplayArray;
@property (nonatomic, retain) NSMutableArray *coursewareDisplayArray;
@property (nonatomic, retain) UILabel *coursewareNumLabe;
@property (nonatomic, retain) UILabel *courseNumLabel;
@property (nonatomic, retain) NSMutableArray *buttonArray;
@property (retain , nonatomic) ASINetworkQueue *downloadQueue;
@end
