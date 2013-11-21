//
//  RegisterContentController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-11-2.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "RegisterContentController.h"
#import "RegisterHistoryController.h"
#define kCheckBtnRect CGRectMake(100, 200, 150, 50)
#define kIsDayForClass 1
#define kLatitudeUp 23.070
#define kLatitudeLow 23.068
#define kLongitudeUp 113.386
#define kLongitudeLow 113.384
#define kRegistered [NSString stringWithFormat:@"registered"]

@interface RegisterContentController ()

@end

@implementation RegisterContentController
{
    NSThread *request;
}
@synthesize checkBtn;
@synthesize  locateManager;
@synthesize activity;
@synthesize hintText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    checkBtn = [[UIButton alloc] initWithFrame:kCheckBtnRect];
    checkBtn.backgroundColor = [UIColor greenColor];
    [checkBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [checkBtn addTarget:self action:@selector(checkBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkBtn];
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(120, 200, 50, 50)];
    activity.backgroundColor = [UIColor clearColor];
    [self.view addSubview:activity];
    
    //[self.navigationItem setTitle:@"签到"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(100,0, 50, 50)];
    [title setBackgroundColor:[UIColor redColor]];
    [title setText:@"签到"];
    [title setTextColor:[UIColor blackColor]];
    [self.navigationItem setTitleView:title];
    
    hintText = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 200, 50)];
    hintText.text = @"正在签到，请稍后";
    hintText.backgroundColor = [UIColor purpleColor];
    hintText.textColor = [UIColor blackColor];
    hintText.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:hintText];
    
    [self startRegister];
}


#pragma Mark - start checking location
- (void)startRegister
{
    self.locateManager = [[CLLocationManager alloc] init];
    self.locateManager.delegate = self;
    self.locateManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locateManager.distanceFilter = 1.0f;
    [self.locateManager startUpdatingLocation];
    [self.activity startAnimating];
    
    CLLocation *current = [[CLLocation alloc] initWithLatitude:self.locateManager.location.coordinate.latitude
                                                     longitude:self.locateManager.location.coordinate.longitude];
    
    NSDate *now = [NSDate date];
    
    //Dao *dao = [Dao sharedDao];
    //int state = [dao requestForCheckIn:@"69"];
    //Firstly check for day, Secondly check for place
    int state = 1;
    if(state == kIsDayForClass) {
        
        if(current.coordinate.latitude <= kLatitudeUp && current.coordinate.latitude >= kLatitudeLow
           && current.coordinate.longitude <= kLongitudeUp && current.coordinate.longitude > kLongitudeLow)
        {
            [self.checkBtn setTitle:@"查看签到历史" forState:UIControlStateNormal];
            [self.hintText setText:@"签到完成啦"];
            
            //TimeStamp
            long timeSp = (long)[now timeIntervalSince1970];
            timeSp = timeSp - timeSp % 86400;

            NSDate *d = [NSDate dateWithTimeIntervalSince1970:timeSp];
            NSLog(@"ddd%@", d);

            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:d forKey:kRegistered];

        }
        else {
            [self.checkBtn setTitle:@"查看签到历史" forState:UIControlStateNormal];
            [self.hintText setText:@"不好意思，你还没到上课地点"];
        }
    }else {
        [self.hintText setText:@"今天不用上课"];
        [self.checkBtn setTitle:@"查看签到历史" forState:UIControlStateNormal];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //[self.activity stopAnimating];
    [self.locateManager stopUpdatingLocation];
    [UIView animateWithDuration:10.0 animations:^{
        [self.activity setAlpha:0.1];
    } completion:^(BOOL finished) {
        [self.activity stopAnimating];
    }];
}

- (IBAction)checkBtnPressed:(id)sender
{
    RegisterHistoryController *controller = [[RegisterHistoryController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
    
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}




@end
