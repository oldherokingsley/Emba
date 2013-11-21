//
//  SetUpView.h
//  setUpView
//
//  Created by 王智锐 on 10/28/13.
//  Copyright (c) 2013 王智锐. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SetUpView;
@protocol SetUpViewDelegate <NSObject>

@required
- (void)closeSetUpView;
@optional
- (void)logoutAccount;

@end
@interface SetUpView : UIView


@property BOOL isPushvar;
@property BOOL isAutoDownLoad;
@property (nonatomic, assign) id <SetUpViewDelegate> delegate;

@property (strong,nonatomic)UILabel *downloadLabel;
@property (strong,nonatomic)UILabel *pushLabel;
@property (strong,nonatomic)UIButton *changePasswdButton;
@property (strong,nonatomic)UIButton *logoutButton;
@property (strong,nonatomic)UIButton *feedBackButton;
@property (strong,nonatomic)UIButton *aboutUsButton;

@property (strong,nonatomic)UIButton *closeButton;

@property (strong,nonatomic)UISwitch *isDownLoad;
@property (strong,nonatomic)UISwitch *isPush;

-(id)initWithDefault;
-(void)slideIn;

- (void)hideSetupView;
- (void)showSetupView;

@end
