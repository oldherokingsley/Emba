//
//  SetUpView.m
//  setUpView
//
//  Created by 王智锐 on 10/28/13.
//  Copyright (c) 2013 王智锐. All rights reserved.
//

#import "SetUpView.h"

#define SCREENWIDTH 1024
#define SCREENHEIGHT 768
#define SETUPWIDTH 405
#define SETUPHEIGHT 455
@implementation SetUpView
@synthesize isPushvar,isAutoDownLoad;
@synthesize closeButton,downloadLabel,pushLabel,isDownLoad,isPush;
@synthesize changePasswdButton ,logoutButton;
@synthesize feedBackButton,aboutUsButton;
float durationOfAnimation = 2.0f;

-(id)initWithDefault{
    NSLog(@"hero");
    return [self initWithFrame:CGRectMake(SCREENWIDTH/2-SETUPWIDTH/2, SETUPHEIGHT / 2 + 200, SETUPWIDTH, SETUPHEIGHT)];
}

-(void)slideIn{
    CGRect startRect = CGRectMake(SCREENWIDTH/2-SETUPWIDTH/2, -SETUPHEIGHT, SETUPWIDTH, SETUPHEIGHT);
    CGRect endRect =   CGRectMake(SCREENWIDTH/2-SETUPWIDTH/2, SCREENHEIGHT/2-SETUPHEIGHT/2, SETUPWIDTH, SETUPHEIGHT);
    //SetUpView *view = [[SetUpView alloc] initWithDefault];
    self.frame = startRect;
    self.alpha = 1.0f;
    [UIView animateWithDuration:durationOfAnimation delay:0.0f
                        options:    UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
        self.frame = endRect;
    } completion:^(BOOL finished) {
    }];
    NSLog(@"finish");
    NSLog(@"%f",self.frame.origin.y);
}

- (void)hideSetupView{
    CGRect rect = self.frame;
    rect.origin.y += 200;
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = rect;
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        
    }];
}
- (void)showSetupView{
    CGRect rect = self.frame;
    rect.origin.y -= 200;
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = rect;
        self.alpha = 1.0f;
    } completion:^(BOOL finished){
    
    }];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        isAutoDownLoad = [(NSNumber*)[userDefault objectForKey:@"isAutoDownLoad"] boolValue];
        isPushvar =  [(NSNumber*)[userDefault objectForKey:@"isPush"] boolValue];
        
        isAutoDownLoad = NO;
        UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"setting_bg"]];
//        [self setBackgroundColor:[UIColor blueColor]];
        [self setBackgroundColor:bgColor];
        [self initWithBar];
        [self initWithDownLoad];
        [self initWithPush];
        [self initWithChangePasswd];
        [self initWithLogout];
        [self initWithFeedBack];
        [self initWithAboutUs];
    }
    return self;
}

-(void)initWithBar{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, 44);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:frame];
    [self addSubview:toolBar];
    [toolBar setBackgroundImage:[UIImage imageNamed:@"setting_nav_bar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
//    UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"setting_nav_back"]];
//    [toolBar setBackgroundColor:[UIColor redColor]];
//    [toolBar setBackgroundColor:bgColor];
    [self initWithButton:toolBar];
}
         
-(void)initWithButton:(UIToolbar*)toolBar{
    CGRect frame = CGRectMake(0,0, 40, 50);
    closeButton = [[UIButton alloc] initWithFrame:frame];
    //到时换图
    [closeButton setTitle:@"返回" forState:UIControlStateNormal];
    
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolBar addSubview:closeButton];
    CGRect titleFrame = toolBar.frame;
    UILabel *title = [[UILabel alloc]initWithFrame:titleFrame];
    [title setText:@"设置"];
    [title setTextColor:[UIColor blackColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [toolBar addSubview: title];
}

-(void)initWithDownLoad{
    CGRect downloadLabelFrame = CGRectMake(50, 100, 200, 20);
    downloadLabel = [[UILabel alloc]initWithFrame:downloadLabelFrame];
    [downloadLabel setText:@"自动下载"];
    [downloadLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:downloadLabel];
    CGRect isDownLoadFrame = CGRectMake(250,100,80,20);
    isDownLoad = [[UISwitch alloc] initWithFrame:isDownLoadFrame];
    isDownLoad.on = NO;
    [self addSubview:isDownLoad];
    [isDownLoad addTarget:self action:@selector(changeAutoDownLoad:) forControlEvents:UIControlEventValueChanged];
}

-(void)initWithPush{
    CGRect pushLabelFrame = CGRectMake(50, 150, 200, 20);
    pushLabel = [[UILabel alloc]initWithFrame:pushLabelFrame];
    [pushLabel setText:@"推送开关"];
    [pushLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:pushLabel];
    CGRect isPushFrame = CGRectMake(250,150,80,20);
    isPush = [[UISwitch alloc]initWithFrame:isPushFrame];
    isPush.on = NO;
    [self addSubview: isPush];
    [isPush addTarget:self action:@selector(changePush:) forControlEvents:UIControlEventValueChanged];
}
         
-(void)initWithChangePasswd{
    CGRect frame = CGRectMake(50, 200, 80, 20);
    changePasswdButton = [[UIButton alloc]initWithFrame:frame];
    [changePasswdButton setTitle:@"修改密码" forState:UIControlStateNormal];
    [changePasswdButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changePasswdButton addTarget:self action:@selector(changePasswd:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:changePasswdButton];
}

-(void)initWithLogout{
    CGRect frame = CGRectMake(50,250,80,20 );
    logoutButton = [[UIButton alloc] initWithFrame:frame];
    [logoutButton setTitle:@"注销" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [logoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:logoutButton];
}

-(void)initWithFeedBack{
    CGRect frame = CGRectMake(50,300, 80, 20);
    feedBackButton= [[UIButton alloc]initWithFrame:frame];
    [feedBackButton setTitle:@"意见反馈" forState:UIControlStateNormal];
    [feedBackButton addTarget:self action:@selector(feedBack:) forControlEvents:UIControlEventTouchUpInside];
    [feedBackButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:feedBackButton];
}

-(void)initWithAboutUs{
    CGRect frame = CGRectMake(50,350, 80, 20);
    aboutUsButton = [[UIButton alloc] initWithFrame:frame];
    [aboutUsButton setTitle:@"关于" forState:UIControlStateNormal];
    [aboutUsButton addTarget:self action:@selector(AboutUs:) forControlEvents:UIControlEventTouchUpInside];
    [aboutUsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:aboutUsButton];
}

-(void)AboutUs:(id)sender{
    //弹出关于我们
    NSLog(@"关于我们");
}

-(void)feedBack:(id)sender{
    //弹出意见反馈页
    NSLog(@"反馈页");
}

-(void)logout:(id)sender{
    //调用注销回调
    [self.delegate logoutAccount];
    NSLog(@"注销");
//    [self removeFromSuperview];
}

-(void)changePasswd:(id)sender{
    //弹出的页面吧我猜。
    //动画效果
}

-(void)close:(id)sender{
//    [self removeFromSuperview];
    [self.delegate closeSetUpView];
}


//使用自动下载回调的时候可能加一个alertview之类的弹窗提示会比较好。防止用户不断改变switch的值。
-(void)changeAutoDownLoad:(id)sender{
    if(isDownLoad.on && isDownLoad.on!= isAutoDownLoad){
        NSLog(@"自动下载开");
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSNumber *temp = [NSNumber numberWithBool:isDownLoad.on];
        [userdefault setObject:temp forKey:@"isAutoDownLoad"];
        isAutoDownLoad = isDownLoad.on;
        //打开自动下载。
        //调用自动下载机制
    }else if(!isDownLoad.on && isDownLoad.on != isAutoDownLoad){
        NSLog(@"自动下载关");
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSNumber *temp = [NSNumber numberWithBool:isDownLoad.on];
        [userdefault setObject:temp forKey:@"isAutoDownLoad"];
        isAutoDownLoad = isDownLoad.on;
        //关闭自动下载
        //暂停当前下载的东西
    }
}

-(void)changePush:(id)sender{
    if(isPush.on && isPush.on != isPushvar){
        NSLog(@"推送开");
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSNumber *temp = [NSNumber numberWithBool:isPush.on];
        [userdefault setObject:temp forKey:@"isPush"];
        isPushvar = isPush.on;
        //调用接受推送回调
    }else if(!isPush.on && isPush.on != isPushvar){
        NSLog(@"推送关");
        //调用关闭推送回调
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSNumber *temp = [NSNumber numberWithBool:isPush.on];
        [userdefault setObject:temp forKey:@"isPush"];
        isPushvar = isPush.on;
    }
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
