//
//  SearchViewController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-18.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "SearchViewController.h"
#import "SysbsModel.h"
#import "MyCourse.h"
#import "Course.h"
#import "File.h"
#import "CourseItem.h"
#import "CoursewareItem.h"
#import "MRCircularProgressView.h"
#import "UIButton+associate.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+category.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "UITapGestureRecognizer+category.h"
#import "CoursewareViewController.h"
NSString *PDFFolderName2 = @"PDF";
NSString *NOTEFolderName2 = @"NOTE";
#define PROGRESS_TAG 111111
#define MAX_DOWNLOAD_NUM 3


@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize searchBar;
@synthesize courseDisplayArray;
@synthesize courseOriginArray;
@synthesize courseSV;
@synthesize coursewareDisplayArray;
@synthesize coursewareOriginArray;
@synthesize coursewareSV;
@synthesize courseNumLabel;
@synthesize coursewareNumLabel;
@synthesize buttonArray;
@synthesize downloadQueue;
@synthesize progressArray;
@synthesize buttonDisplayArray;


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
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(backToMainPage:)];
    [backItem setImage:[UIImage imageNamed:@"pptsearch_cancle"]];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.rightBarButtonItem = backItem;
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 1024 - 50 - 100, 44)];
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(50, 0, 1024 - 50 - 100, 44)];
    searchView.backgroundColor = [UIColor clearColor];
    [searchView addSubview:searchBar];
    self.navigationItem.titleView = searchBar;

    if (![self downloadQueue]) {
        [self setDownloadQueue:[[ASINetworkQueue alloc]init]];
    }
    [self.downloadQueue reset];
    [self.downloadQueue setMaxConcurrentOperationCount:MAX_DOWNLOAD_NUM];      //最大同时下载数
    [self.downloadQueue setShowAccurateProgress:YES];        //是否显示详细进度
    [self.downloadQueue setShouldCancelAllRequestsOnFailure:NO];
    [self.downloadQueue setDelegate:self];
//    [self.downloadQueue setRequestDidFailSelector:@selector(queueFailed)];
//    [self.downloadQueue setRequestDidFinishSelector:@selector(queueFinished)];
//    [self.downloadQueue setRequestDidStartSelector:@selector(queueStarted)];
//    [self initSrollViewDatas];
    
    CGFloat viewY = 40;
    coursewareNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, viewY, 300, 50)];
    [coursewareNumLabel setTextColor:[UIColor redColor]];
    [coursewareNumLabel setText:@"共找到0个课件"];
    [self.view addSubview:coursewareNumLabel];
    
    viewY += (50 + 0);
    coursewareSV = [[UIScrollView alloc]initWithFrame:CGRectMake(50, viewY, 1024 - 50, 280)];
    [self.view addSubview:coursewareSV];
    
    viewY += (280);
    courseNumLabel = [[UILabel alloc]
                      initWithFrame:CGRectMake(50, viewY, 300, 50)];
    [courseNumLabel setText:@"共找到0个课程"];
    [courseNumLabel setTextColor:[UIColor redColor]];
    [self.view addSubview:courseNumLabel];
    
    viewY += (50 + 0);
    courseSV = [[UIScrollView alloc]initWithFrame:CGRectMake(50, viewY, 1024 - 50, 280)];
    [self.view addSubview:courseSV];
//    [self setScrollViewDatas];
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(initSrollViewDatas) object:nil];
    [thread start];
    
	// Do any additional setup after loading the view.
}
- (void) queueFailed{
    NSLog(@"failed");
}
- (void) queueFinished{
    NSLog(@"finished");
}
- (void) queueStarted{
    NSLog(@"started");
}

- (void) backToMainPage:(UIBarButtonItem *)backItem{

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
}
- (void)dealloc{
    for (ASIHTTPRequest *request in self.downloadQueue.operations) {
        NSLog(@"cancel");
        [request clearDelegatesAndCancel];
    }
    for (MRCircularProgressView *progress in progressArray) {
        [progress removeLink];
    }

}

- (void) initSrollViewDatas{
    buttonArray = [[NSMutableArray alloc]init];
    courseOriginArray = [[NSMutableArray alloc]init];
    courseDisplayArray = [[NSMutableArray alloc]init];
    coursewareDisplayArray = [[NSMutableArray alloc]init];
    coursewareOriginArray = [[NSMutableArray alloc]init];
    progressArray = [[NSMutableArray alloc]init];
    buttonDisplayArray = [[NSMutableArray alloc]init];
    
    SysbsModel *sysbsModel = [SysbsModel getSysbsModel];
    MyCourse *myCourse = sysbsModel.myCourse;
    courseOriginArray = myCourse.courseArr;
    courseDisplayArray = myCourse.courseArr;
    for (int i = 0; i < [courseOriginArray count]; i ++) {
        Course *course = [courseOriginArray objectAtIndex:i];
        NSString *courseFolderName = [NSString stringWithFormat:@"%d",course.cid];
        NSString *contents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *PDFPath = [contents stringByAppendingPathComponent:PDFFolderName2];
        NSString *PDFCoursePath = [PDFPath stringByAppendingPathComponent:courseFolderName];
        [self createDir:PDFCoursePath];
        for (int k = 0; k < [course.fileArr count]; k ++) {
            File *file = [course.fileArr objectAtIndex:k];
            CoursewareItem *item = [[CoursewareItem alloc]init];
            item.cid = courseFolderName;
            item.PDFName = file.fileName;
            item.PDFURL = file.filePath;
            item.PDFPath = [PDFCoursePath stringByAppendingPathComponent:item.PDFName];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:item.PDFPath]) {
                UIImage *fImage = [self getFirstPageFromPDF:item.PDFPath];
                [item setPDFFirstImage:fImage];
            }
            else
                [item setPDFFirstImage:nil];
            [coursewareOriginArray addObject:item];
            [coursewareDisplayArray addObject:item];

        }
    }
    [self performSelectorOnMainThread:@selector(setScrollViewDatas) withObject:nil waitUntilDone:YES];
    
}

- (void) setScrollViewDatas{
    for (UIView *subView in courseSV.subviews) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in coursewareSV.subviews) {
        [subView removeFromSuperview];
    }
    [coursewareNumLabel setText:[NSString stringWithFormat:@"共找到%d个课件",[coursewareDisplayArray count]]];
    [courseNumLabel setText:[NSString stringWithFormat:@"共找到%d个课程",[courseDisplayArray count]]];
    [coursewareSV setContentSize:CGSizeMake([coursewareDisplayArray count] * 250, 280)];
    buttonArray = [NSMutableArray array];
    for (int i = 0; i < [coursewareDisplayArray count]; i ++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(250 * i + 24, 20, 226, 180)];
        [button setTag:i + 1];
        [self.buttonArray addObject:button];
        
        //            UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(13, 140, 200, 10)];
        MRCircularProgressView *progressView = [[MRCircularProgressView alloc]initWithFrame:CGRectMake(63, 40, 100, 100)];
        [progressView setHidden:YES];
        [progressView setTag:PROGRESS_TAG];
        //            [progressView setProgressViewStyle:UIProgressViewStyleBar];
        [button addSubview:progressView];
        [self.progressArray addObject:progressView];
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(250 * i + 24, 280 - 20 - 50, 226, 50)];
        [label setHidden:YES];
        [label setLineBreakMode:NSLineBreakByCharWrapping];
        [label setNumberOfLines:0];
        //[label setText:name];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:i * 10 + 10];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i],@"index", nil];
        [button setMyDict:dict];
        CoursewareItem *item = [self.coursewareDisplayArray objectAtIndex:i];
        NSString *PDFName = item.PDFName;
        UIImage *PDFFirstImage = item.PDFFirstImage;
        //        NSString *PDFPath = item.PDFPath;
        NSString *PDFURL = item.PDFURL;
        for (ASIHTTPRequest *request in self.downloadQueue.operations) {
            if ([request.originalURL isEqual:[NSURL URLWithString:PDFURL]]) {
                request.tag = i;
                
                [request setDownloadProgressDelegate:progressView];
                [progressView setHidden:NO];
            }
        }
        if (PDFFirstImage != nil) {
            
            //            NSLog(@"PDFFirstImage %d",index);
            [button setImage:PDFFirstImage forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
            
            
            //            [button removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            
            
            
            [button addTarget:self action:@selector(openCourseware:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            
            //            [button removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            
            [button setImage:nil forState:UIControlStateNormal];
            [button addTarget:self action:@selector(courseItemAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        UIImage *image = [UIImage imageNamed:@"pptsearch_ppt"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        
        
        [label setHidden:NO];
        [label setText:PDFName];

        
        
        [coursewareSV addSubview:button];
        [coursewareSV addSubview:label];
        [courseSV setContentOffset:CGPointZero];
        [coursewareSV setContentOffset:CGPointZero];
    }
    
    int courseNumber = [courseDisplayArray count];
    [self.courseSV setContentSize:CGSizeMake(courseNumber * 250,280)];
    for (int i = 0;  i < courseNumber; i ++) {
        Course *course = [courseDisplayArray objectAtIndex:i];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:course.courseName,@"courseName",course.teacherName,@"teachName",@"2013/11/11",@"date", nil];
        CourseItem *courseItem = [[CourseItem alloc]initWithFrame:CGRectMake(20 + i * 250,20, 235, 235) :dict];
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToCourseware:)];
        NSDictionary *myDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:course.cid],@"tag", nil];
        [singleTapGesture setMyDict:myDict];
        
        [courseItem addGestureRecognizer:singleTapGesture];
        [self.courseSV addSubview:courseItem];
    }


}

- (void)openCourseware:(id)sender
{
    ////
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = button.myDict;
    int index = [(NSNumber *)[dict objectForKey:@"index"] integerValue];
    CoursewareItem *item = [self.coursewareDisplayArray objectAtIndex:index];
    NSString *filePath = item.PDFPath;
    
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
        
        NSString *contents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *courseFolderName = item.cid;
        NSString *NOTEPath = [contents stringByAppendingPathComponent:NOTEFolderName2];
        NSString *NOTECoursePath = [NOTEPath stringByAppendingPathComponent:courseFolderName];
        NSString *NOTEPDFPath = [NOTECoursePath stringByAppendingPathComponent:[filePath lastPathComponent]];
        [self createDir:NOTEPDFPath];
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
        readerViewController.notePath = NOTEPDFPath;
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        //#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
        //		[self.navigationController pushViewController:readerViewController animated:YES];
        
        //#else // present in a modal view controller
        
		readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        readerViewController.modalPresentationStyle = UIModalPresentationCustom;
        readerViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
		[self presentViewController:readerViewController animated:YES completion:nil];
        
        //#endif // DEMO_VIEW_CONTROLLER_PUSH
	}
    
    
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

//点击单个课件下载
- (void) courseItemAction:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = button.myDict;
    int index = [(NSNumber *)[dict objectForKey:@"index"] integerValue];
    NSLog(@"index %d",index);
    [self downloadPDF:index];
    
    [self.downloadQueue go];
    
}
//下载单个课件
- (void) downloadPDF:(int)index
{
    UIButton *button = (UIButton *)[buttonArray objectAtIndex:index];
    
    CoursewareItem *item = [coursewareDisplayArray objectAtIndex:index];
    NSURL *url = [NSURL URLWithString:item.PDFURL];
    NSLog(@"url %@",url);
    
    NSString *filePath = item.PDFPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"filePath %@",filePath);
    //判断是否已存在文件
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"return");
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    //判断是否已经存在队列中，
    for (ASIHTTPRequest *tempRequest in [self.downloadQueue operations]) {
        if ([tempRequest.originalURL isEqual:request.originalURL]) {
            [tempRequest clearDelegatesAndCancel];
            [request clearDelegatesAndCancel];
            return;
        }
    }
    
    MRCircularProgressView *progress = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
    [progress setHidden:NO];
    progress.progress = 0;
    
    [request setTag:index];
    [request setDelegate:self];
//    [request clearDelegatesAndCancel];
    
    [request setDidFinishSelector:@selector(requestDone:)];     //下载完成处理
    [request setDidFailSelector:@selector(requestWentWrong:)];  //下载出错处理
    [request setDownloadProgressDelegate:progress];//设置每个任务的进度条信息
    [request setShowAccurateProgress:YES];
    
    NSDictionary *myDict = [NSDictionary dictionaryWithObjectsAndKeys:item,@"item", nil];
    [request setMyDict:myDict];
    [request setShouldContinueWhenAppEntersBackground:YES];
    
    [[self downloadQueue] addOperation:request];
    
}

//下载完成
- (void) requestDone:(ASIHTTPRequest *)request{
    int index = request.tag;
    NSDictionary *myDict = request.myDict;
    CoursewareItem *item = [myDict objectForKey:@"item"];
    NSString *filePath = item.PDFPath;
    [request.responseData writeToFile:filePath atomically:YES];
    UIImage *image = [self getFirstPageFromPDF:filePath];
    item.PDFFirstImage = image;
//    if (index > [displayArray count]) {
//        return;
//    }
    
    UIButton *button = [self.buttonArray objectAtIndex:index];
    NSDictionary *dict = button.myDict;
    index = [(NSNumber *)[dict objectForKey:@"index"] intValue];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [button removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(openCourseware:) forControlEvents:UIControlEventTouchUpInside];
    MRCircularProgressView *progressView = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
    [progressView setHidden:YES];
    NSLog(@"finish");
}
/*
//下载后加载图片
- (void) loadImageThred:(NSDictionary *)dict{
    ASIHTTPRequest *request = (ASIHTTPRequest *)[dict objectForKey:@"request"];
    
    NSDictionary *myDict = request.myDict;
    CoursewareItem *item = [myDict objectForKey:@"item"];
    NSString *filePath = item.PDFPath;
    [request.responseData writeToFile:filePath atomically:YES];
    UIImage *image = [self getFirstPageFromPDF:filePath];
    item.PDFFirstImage = image;
    NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:request,@"request",image,@"image", nil];
    [self performSelectorOnMainThread:@selector(displayImage:) withObject:newDict waitUntilDone:YES];
}

//加载完图片显示出来
- (void) displayImage:(NSDictionary *)dict{
    ASIHTTPRequest *request = (ASIHTTPRequest *)[dict objectForKey:@"request"];
    UIImage *image = (UIImage *)[dict objectForKey:@"image"];
    int index = request.tag;
    UIButton *button = [self.buttonArray objectAtIndex:index];
    NSDictionary *myDict = button.myDict;
    index = [(NSNumber *)[myDict objectForKey:@"index"] intValue];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [button removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(openCourseware:) forControlEvents:UIControlEventTouchUpInside];
    MRCircularProgressView *progressView = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
    
    [progressView setHidden:YES];
    
}
 */

//下载出错处理
- (void) requestWentWrong:(ASIHTTPRequest *)request{
    NSLog(@"download error : %@",request.error );
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"出错啦！" message:@"网络连接出错，请检查网络！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    
    int index = request.tag;
    UIButton *button = [self.buttonArray objectAtIndex:index];
    //    UIProgressView *progressView = (UIProgressView *)[button viewWithTag:PROGRESS_TAG];
    MRCircularProgressView *progressView = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
    [progressView setHidden:YES];
}





//create a director
- (void) createDir:(NSString *)dirPath
{
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
}
- (UIImage *)getFirstPageFromPDF:(NSString *)aFilePath{
    //	CFStringRef path;
    //	CFURLRef url;
	CGPDFDocumentRef document;
    
    NSURL *nsurl = [[NSURL alloc]initFileURLWithPath:aFilePath isDirectory:NO];
    
    CFURLRef url = (__bridge CFURLRef)nsurl;
    //    CFURLRef url = CFRetain((__bridge CFTypeRef)(nsurl));
    
    
	document = CGPDFDocumentCreateWithURL(url);
    //	CFRelease(url);
    
	int count = CGPDFDocumentGetNumberOfPages (document);
    if (count == 0) {
		return NULL;
    }
    
    //	return document;
    
    CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
    
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    pageRect.origin = CGPointZero;
    
    //开启图片绘制 上下文
    UIGraphicsBeginImageContext(pageRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置白色背景
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,pageRect);
    
    CGContextSaveGState(context);
    
    //进行翻转
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, pageRect, 0, true));
    
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGPDFDocumentRelease(document);
    
    //CGPDFDocumentRelease(document);
    //UIImage *image = [self getUIImageFromPDFPage:0 pdfPage:page];
    //    CGPDFPageRelease(page);
    //CGPDFDocumentRelease(document);
    return image;
    //return image;
    //    CGPDFDocumentRelease(document), document = NULL;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    
	[self dismissViewControllerAnimated:YES completion:NULL];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

#pragma serchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    [self.searchBar resignFirstResponder];
    NSString *searchText = _searchBar.text;
    NSLog(@"click");
    if (searchText!=nil && searchText.length>0) {
        self.coursewareDisplayArray= [NSMutableArray array];
        self.buttonDisplayArray = [NSMutableArray array];
        for (int i = 0 ; i < [coursewareOriginArray count];i ++) {
            CoursewareItem *item = [coursewareOriginArray objectAtIndex:i];
//            UIButton *button = [buttonArray objectAtIndex:i];
            if ([self isMatch:searchText :item.PDFName]) {
                [self.coursewareDisplayArray addObject:item];
//                [self.buttonDisplayArray addObject:button];
                //                NSLog(@"%d",[displayArray count]);
            }
        }
        
        self.courseDisplayArray = [NSMutableArray array];
        for (int i = 0; i < [courseOriginArray count]; i ++) {
            Course *course = [courseOriginArray objectAtIndex:i];
            if ([self isMatch:searchText :course.courseName]) {
                [self.courseDisplayArray addObject:course];
            }
        }
        
//        [self.courseTableView reloadData];
        [self setScrollViewDatas];
    }
    else
    {
        self.coursewareDisplayArray = [NSMutableArray arrayWithArray:coursewareOriginArray];
        self.buttonDisplayArray = [NSMutableArray arrayWithArray:buttonArray];
//        [self.courseTableView reloadData];
        [self setScrollViewDatas];
    }

}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self searchBar:self.searchBar textDidChange:nil];
    [self.searchBar resignFirstResponder];
    //    NSLog(@"cancel");
}

- (BOOL)isMatch:(NSString *)searchText :(NSString *)originalText{
    BOOL result = YES;
    int start = 0;
    for (int i = 0; i < searchText.length; i ++) {
        unichar c = [searchText characterAtIndex:i];
        for (int k = start; k < originalText.length; k ++) {
            if (c == [originalText characterAtIndex:k]) {
                start = k + 1;
                break;
            }
            if (k == originalText.length - 1) {
                result = NO;
            }
        }
    }
    
    return result;
}

@end
