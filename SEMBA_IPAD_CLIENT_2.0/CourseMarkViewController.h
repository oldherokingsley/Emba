//
//  CourseMarkViewController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-7.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderDocument.h"
#import "MarkToolBar.h"
@class CourseMarkViewController;
@protocol CourseMarkViewDelegate <NSObject>

@required

- (void)courseMarkViewController:(CourseMarkViewController *)viewController gotoPage:(NSInteger)page;
- (void)dismissMarkViewControoler:(CourseMarkViewController *)viewController;

@end

@interface CourseMarkViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MarkToolBarDelegate>

@property (nonatomic, weak, readwrite) id <CourseMarkViewDelegate>delegate;
@property (nonatomic, retain) UITableView *markTableView;
@property (nonatomic, retain) ReaderDocument *document;
@property (nonatomic, retain) NSMutableArray *displayImageArray;
@property (nonatomic, retain) NSMutableArray *displayTextArray;
@property (nonatomic, retain) NSMutableArray *originalImageArray;
@property (nonatomic, retain) NSMutableArray *originalTextArray;
@property (nonatomic, retain) NSMutableArray *bookMarkedArray;
@property (nonatomic, retain) NSMutableArray *deleteMarkedArray;
@property (nonatomic) CGRect imageRect;
@property (nonatomic, retain) MarkToolBar *markToolBar;
@property (nonatomic) int pageAngle;

- (id)initWithReaderDocument:(ReaderDocument *)object;
@end
