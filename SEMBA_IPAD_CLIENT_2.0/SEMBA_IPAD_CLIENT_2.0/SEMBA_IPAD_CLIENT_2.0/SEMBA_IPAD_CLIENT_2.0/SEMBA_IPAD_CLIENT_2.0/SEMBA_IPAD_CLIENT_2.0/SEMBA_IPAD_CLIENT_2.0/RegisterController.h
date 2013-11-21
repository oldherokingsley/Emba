//
//  RegisterController.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-30.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterController : UIViewController
@property (nonatomic) CGSize *frameSize;

+ (RegisterController*)sharedRegisterController;

- (void)presentWithContentController:(UIViewController *)contentController animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;

@end
