//
//  MainPageViewController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-10-28.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "MainPageViewController.h"
#import "CourseItem.h"
#import "UITapGestureRecognizer+category.h"
#import "CoursewareViewController.h"
#import "Dao.h"
#import "MyCourse.h"
#import "Course.h"
#import "SysbsModel.h"
#import "User.h"


#define START_Y 0
@interface MainPageViewController ()

@end

@implementation MainPageViewController
@synthesize scrollView;
@synthesize mainImageView;
@synthesize courseImageView;
@synthesize courseLabel;
@synthesize classRoomLabel;
@synthesize teachLabel;
@synthesize dateLabel;
@synthesize courseButton;
@synthesize courseArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    courseArray = [[NSArray alloc]init];
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(loadDataSelector:) object:nil];
//    [thread start];
    
    NSLog(@"%f %f %f %f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
    self.title = @"课程";
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    [button setFrame:CGRectMake(10, 0, 44, 44)];
//    [button setTitle:@"菜单" forState:UIControlStateNormal];
//    [self.navigationController.navigationBar addSubview:button];
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]initWithTitle:@"菜单" style:UIBarButtonItemStyleBordered target:self action:@selector(menuAction:)];
//    self.navigationItem.leftBarButtonItems = [[NSArray alloc]initWithObjects:menuButton, nil];
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [scrollView setBackgroundColor:[UIColor whiteColor]];//课程页背景
    
    [self.view addSubview:scrollView];
    
    mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, START_Y, 753, 224)];
    [mainImageView setBackgroundColor:[UIColor greenColor]];
    [self.scrollView addSubview:mainImageView];
    
    courseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(752, START_Y, 272, 224)];
    [courseImageView setBackgroundColor:[UIColor blueColor]];
    [self.scrollView addSubview:courseImageView];
    
    courseLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 30)];
    [courseLabel setText:@"战略管理"];
    UIFont *font = [UIFont systemFontOfSize:25];
    [courseLabel setFont:font];
    [self.courseImageView addSubview:courseLabel];
    
    teachLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 100, 30)];
    [teachLabel setText:@"谁谁谁"];
    [teachLabel setFont:font];
    [self.courseImageView addSubview:teachLabel];
    
    classRoomLabel= [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 100, 30)];
    [classRoomLabel setText:@"M101"];
    [classRoomLabel setFont:font];
    [self.courseImageView addSubview:classRoomLabel];
    
    dateLabel= [[UILabel alloc]initWithFrame:CGRectMake(20, 110, 100, 30)];
    [dateLabel setText:@"2013/11/11"];
    [dateLabel setFont:font];
    [self.courseImageView addSubview:dateLabel];
    
    courseButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 140, 100, 30)];
    [courseButton setTitle:@"查看相关课件" forState:UIControlStateNormal];
    [self.courseImageView addSubview:courseButton];
    
    
    int courseNumber = 7;
    int rowNum = (courseNumber % 4 == 0) ? (courseNumber / 4) : (courseNumber / 4 + 1);
    [self.scrollView setContentSize:CGSizeMake(1024, START_Y + 224 + 20 + rowNum * 250)];
    for (int i = 0;  i < courseNumber; i ++) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"战略管理",@"courseName",@"谁谁谁",@"teachName",@"2013/11/11",@"date", nil];
        CourseItem *courseItem = [[CourseItem alloc]initWithFrame:CGRectMake(20 + (i % 4) * 250,START_Y + 224 + 20 + (i / 4) * 250, 235, 235) :dict];
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToCourseware:)];
        NSDictionary *myDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i],@"tag", nil];
        [singleTapGesture setMyDict:myDict];
        
        [courseItem addGestureRecognizer:singleTapGesture];
        [self.scrollView addSubview:courseItem];
    }
    
    
    
	// Do any additional setup after loading the view.
}

- (void)loadDataSelector:(NSThread *)thread{
    Dao *dao = [Dao sharedDao];
    SysbsModel *sysbsModel = [SysbsModel getSysbsModel];
    User *user = [sysbsModel getUser];
    int myCourseRequest = [dao requestForMyCourse:user.uid];
    
    if (myCourseRequest == 1) {
        NSLog(@"myCourse success！");
        MyCourse *myCourse = [sysbsModel getMyCourse];
        courseArray = [myCourse getMyCourse];
        for (int i = 0 ; i < [courseArray count]; i ++) {
            Course *course = [courseArray objectAtIndex:i];
            NSLog(@"coursID %d",course.cid);
        }
    } else if (myCourseRequest == 0) {
        NSLog(@"网络连接失败！");
    } else if (myCourseRequest == -1){
        NSLog(@"服务器出错！");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//跳转到课件页面
- (void)jumpToCourseware:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    NSDictionary *myDict = gesture.myDict;
    int index = [(NSNumber *)[myDict objectForKey:@"tag"] integerValue];
    
    CoursewareViewController *coursewareViewController = [[CoursewareViewController alloc]init];
    coursewareViewController.courseFolderName = [NSString stringWithFormat:@"%d",index];
    [self.navigationController pushViewController:coursewareViewController animated:YES];
}

- (void)menuAction:(id)sender
{
    
}

@end
