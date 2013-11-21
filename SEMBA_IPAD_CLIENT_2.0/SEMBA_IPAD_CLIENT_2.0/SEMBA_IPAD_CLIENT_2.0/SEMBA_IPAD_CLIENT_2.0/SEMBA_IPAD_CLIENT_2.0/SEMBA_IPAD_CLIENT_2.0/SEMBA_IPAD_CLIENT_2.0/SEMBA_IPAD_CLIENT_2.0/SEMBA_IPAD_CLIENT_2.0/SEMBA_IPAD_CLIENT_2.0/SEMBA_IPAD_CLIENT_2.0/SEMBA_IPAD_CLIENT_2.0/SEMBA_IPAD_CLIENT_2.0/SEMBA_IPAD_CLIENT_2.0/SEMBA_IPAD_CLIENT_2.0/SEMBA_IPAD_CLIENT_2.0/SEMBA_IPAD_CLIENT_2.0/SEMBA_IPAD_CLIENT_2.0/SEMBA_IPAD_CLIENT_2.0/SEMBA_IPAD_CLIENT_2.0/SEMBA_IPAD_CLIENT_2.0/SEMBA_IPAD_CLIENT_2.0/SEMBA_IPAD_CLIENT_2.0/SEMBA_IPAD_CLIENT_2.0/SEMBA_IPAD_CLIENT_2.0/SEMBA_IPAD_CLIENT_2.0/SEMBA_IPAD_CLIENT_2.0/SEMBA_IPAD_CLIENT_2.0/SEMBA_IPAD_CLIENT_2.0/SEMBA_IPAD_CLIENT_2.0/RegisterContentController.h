//
//  RegisterContentController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-11-2.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Dao.h"

@interface RegisterContentController : UIViewController<CLLocationManagerDelegate>

@property (nonatomic, retain) UIButton *checkBtn;

@property (nonatomic, strong) CLLocationManager *locateManager;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, strong) UILabel *hintText;

- (IBAction)checkBtnPressed:(id)sender;

@end
