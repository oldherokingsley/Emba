//
//  SetupViewController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-21.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SetupViewController;
@protocol SetupViewControllerDelegate <NSObject>

@optional
- (void)logoutAccount;

@end

@interface SetupViewController : UIViewController
@property (nonatomic, assign) id<SetupViewControllerDelegate> delegate;

@property BOOL isPushvar;
@property BOOL isAutoDownLoad;
@property BOOL isAutoLogin;

@end
