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
@synthesize coursewareNumLabe;
@synthesize buttonArray;
@synthesize downloadQueue;

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
    self.navigationItem.leftBarButtonItem = backItem;
    
    if (![self downloadQueue]) {
        [self setDownloadQueue:[[ASINetworkQueue alloc]init]];
    }
    [self.downloadQueue setMaxConcurrentOperationCount:MAX_DOWNLOAD_NUM];      //最大同时下载数
    [self.downloadQueue setShowAccurateProgress:YES];        //是否显示详细进度
    [self.downloadQueue setShouldCancelAllRequestsOnFailure:NO];
    [self.downloadQueue setDelegate:self];
//    [self.downloadQueue setRequestDidFailSelector:@selector(queueFailed)];
//    [self.downloadQueue setRequestDidFinishSelector:@selector(queueFinished)];
//    [self.downloadQueue setRequestDidStartSelector:@selector(queueStarted)];
    [self initSrollViewDatas];
    
    CGFloat viewY = 40;
    coursewareNumLabe = [[UILabel alloc]initWithFrame:CGRectMake(50, viewY, 300, 50)];
    [coursewareNumLabe setTextColor:[UIColor redColor]];
    [coursewareNumLabe setText:@"共找到0个课件"];
    [self.view addSubview:coursewareNumLabe];
    
    viewY += (50 + 0);
    coursewareSV = [[UIScrollView alloc]initWithFrame:CGRectMake(50, viewY, 1024 - 50, 280)];
    [self.view addSubview:coursewareSV];
    
    viewY += (280 + 40);
    courseNumLabel = [[UILabel alloc]
                      initWithFrame:CGRectMake(50, viewY, 300, 50)];
    [courseNumLabel setText:@"共找到0个课件"];
    [courseNumLabel setTextColor:[UIColor redColor]];
    [self.view addSubview:courseNumLabel];
    
    viewY += (50 + 0);
    courseSV = [[UIScrollView alloc]initWithFrame:CGRectMake(50, viewY, 1024 - 50, 280)];
    [self.view addSubview:courseSV];
    [self setScrollViewDatas];
    
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
    
    [self.downloadQueue reset];
//    [self.downloadQueue setDelegate:nil];
//    [self.downloadQueue cancelAllOperations];
//    for (ASIHTTPRequest *request in self.downloadQueue.operations) {
//        if ([request isExecuting]) {
//            [request clearDelegatesAndCancel];
//            NSLog(@"cancel");
//            [request setDelegate:nil];
//            [request cancel];
    
            
//        }
//    }
//    [self.downloadQueue reset];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initSrollViewDatas{
    buttonArray = [[NSMutableArray alloc]init];
    courseOriginArray = [[NSMutableArray alloc]init];
    courseDisplayArray = [[NSMutableArray alloc]init];
    coursewareDisplayArray = [[NSMutableArray alloc]init];
    coursewareOriginArray = [[NSMutableArray alloc]init];
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
    
}

- (void) setScrollViewDatas{
    [coursewareSV setContentSize:CGSizeMake([coursewareDisplayArray count] * 250, 280)];
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
            [button setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            
            
            //            [button removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            
            
            
            [button addTarget:self action:@selector(openCourseware:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            
            //            [button removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            
            [button setImage:nil forState:UIControlStateNormal];
            [button addTarget:self action:@selector(courseItemAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        UIImage *image = [UIImage imageNamed:@"download_ppt.png"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        
        
        [label setHidden:NO];
        [label setText:PDFName];

        
        
        [coursewareSV addSubview:button];
        [coursewareSV addSubview:label];
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
    
    ASIHTTPRequest *tempRequest = [[ASIHTTPRequest alloc]init];
    //判断是否已经存在队列中，
    for (tempRequest in [self.downloadQueue operations]) {
        if ([tempRequest.originalURL isEqual:request.originalURL]) {
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

//- (void)dealloc{

    
//    [self.downloadQueue cancelAllOperations];
//    [self.downloadQueue reset];
//    self.downloadQueue = nil;

    //    [super dealloc];
//}

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


@end
