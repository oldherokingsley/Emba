//
//  MarkToolBar.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-7.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MarkToolBar;

@protocol MarkToolBarDelegate <NSObject>

@required
- (void)tappedInMarkToolBar:(MarkToolBar *)toolBar edit:(UIButton *)button;
- (void)tappedInMarkToolBar:(MarkToolBar *)toolBar back:(UIButton *)button;
- (void)tappedInMarkToolBar:(MarkToolBar *)toolBar cancel:(UIButton *)button;
- (void)tappedInMarkToolBar:(MarkToolBar *)toolBar finish:(UIButton *)button;



@end
@interface MarkToolBar : UIView
@property (nonatomic, weak, readwrite) id<MarkToolBarDelegate> delegate;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *editButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *finishButton;

@end
