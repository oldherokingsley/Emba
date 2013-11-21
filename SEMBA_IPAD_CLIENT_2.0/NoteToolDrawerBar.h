//
//  NoteToolDrawerBar.h
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-8.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteToolDrawerBar;
@protocol NoteToolDrawerBarDelegate <NSObject>

@required

- (void)tappedInNoteToolDrawerBar:(NoteToolDrawerBar *)toolDrawerBar toolAction:(UIButton *)button;
@optional

- (void)drawerClose:(NoteToolDrawerBar *)toolDrawerBar;
- (void)drawerOpen:(NoteToolDrawerBar *)toolDrawerBar;

@end
@interface NoteToolDrawerBar : UIView

@property (nonatomic, weak, readwrite) id <NoteToolDrawerBarDelegate> delegate;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) CGPoint closePoint;
@property (nonatomic) CGPoint openPoint;
@property (nonatomic, retain) UIView *parentView;
@property (nonatomic) CGRect parentRect;
@property (nonatomic, retain) UIImageView *arrowIV;
@property (nonatomic, retain) NSMutableArray *buttonArray;
@property (nonatomic, retain) NSMutableArray *imageNameNArray;
@property (nonatomic, retain) NSMutableArray *imageNameHArray;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;

- (void)hideNoteToolDrawerBar;
- (void)showNoteToolDrawerBar;

- (void)closeAllButton;

- (void)openOrCloseToolBar;

- (id)initWithFrame:(CGRect)frame parentView :(UIView *) parentview;

@end
