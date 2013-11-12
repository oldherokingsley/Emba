//
//	ReaderDemoController.m
//	Reader v2.7.0
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "CoursewareViewController.h"
#import "ReaderViewController.h"
#import "UIButton+associate.h"
#import "ASIHTTPRequest.h"
#import "CoursewareItem.h"
#import "ASIHTTPRequest+category.h"
#import "MRCircularProgressView.h"
#import "File.h"
#import "Course.h"
#import "MyCourse.h"
#import "SysbsModel.h"
#define ITEM_NUM_IN_ROW     4
#define MAX_DOWNLOAD_NUM    3
#define PROGRESS_TAG 111111

NSString *PDFFolderName = @"PDF";
NSString *NOTEFolderName = @"NOTE";


@interface CoursewareViewController () <ReaderViewControllerDelegate>

@end

@implementation CoursewareViewController
@synthesize courseTableView;
@synthesize PDFPathArray;
@synthesize PDFUrlArray;
@synthesize progressArray;
@synthesize downloadQueue;
@synthesize buttonArray;
@synthesize courseFolderName;
@synthesize searchBar;
@synthesize displayArray;
@synthesize originalArray;
@synthesize displayButtonArray;
@synthesize displayProgArray;
@synthesize buttonNumber;
#pragma mark Constants

#define DEMO_VIEW_CONTROLLER_PUSH FALSE

#pragma mark UIViewController methods

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if (![self downloadQueue]) {
        [self setDownloadQueue:[[ASINetworkQueue alloc]init]];
    }
    [self.downloadQueue setMaxConcurrentOperationCount:MAX_DOWNLOAD_NUM];      //最大同时下载数
    [self.downloadQueue setShowAccurateProgress:YES];        //是否显示详细进度
    
    
    self.courseTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    self.courseTableView.delegate = self;
    self.courseTableView.dataSource = self;
    [self.courseTableView setSeparatorColor:[UIColor clearColor]];
    [self.courseTableView setSectionIndexColor:[UIColor clearColor]];
    [self.courseTableView setAllowsSelection:NO];
    
    [self.view addSubview:self.courseTableView];
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(initDatas) object:nil];
    [thread start];
    
	self.view.backgroundColor = [UIColor clearColor]; // Transparent

	self.title = @"课件";
    
    
    UIBarButtonItem *downloadAllButton = [[UIBarButtonItem alloc]initWithTitle:@"下载全部" style:UIBarButtonItemStyleBordered target:self action:@selector(downloadAllAction:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:downloadAllButton, nil];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(800 - 150, 0, 150, 44)];
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [self.searchBar setPlaceholder:@""];
    self.searchBar.delegate = self;
    
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 800, 44)];
    searchView.backgroundColor = [UIColor clearColor];
    [searchView addSubview:searchBar];
    
    self.navigationItem.titleView = searchView;
}

- (void) initDatas{
    self.PDFUrlArray = [[NSMutableArray alloc]init];
    self.PDFPathArray = [[NSMutableArray alloc]init];
    self.progressArray = [[NSMutableArray alloc]init];
    self.buttonArray = [[NSMutableArray alloc]init];
    self.displayButtonArray = [[NSMutableArray alloc]init];
    
    self.originalArray = [[NSMutableArray alloc]init];
    self.displayArray = [[NSMutableArray alloc]init];
    NSString *contents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *PDFPath = [contents stringByAppendingPathComponent:PDFFolderName];
    NSString *PDFCoursePath = [PDFPath stringByAppendingPathComponent:courseFolderName];
    
    int cid = [courseFolderName intValue];
    SysbsModel *sysbsModel = [SysbsModel getSysbsModel];
    MyCourse *myCourse = sysbsModel.myCourse;
    Course *course = [myCourse findCourse:cid];
    
    [self createDir:PDFCoursePath];
    for (int i = 0 ; i < [course.fileArr count]; i ++) {
        File *file = [course.fileArr objectAtIndex:i];
        NSString *url = file.filePath;
        NSString *fileName = file.fileName;
        NSString *filePath = [PDFCoursePath stringByAppendingPathComponent:fileName];
        [self.PDFUrlArray addObject:url];
        [self.PDFPathArray addObject:filePath];
    }
    for (int i = 0 ; i < [self.PDFUrlArray count]; i ++) {
        CoursewareItem *item = [[CoursewareItem alloc]init];
        [item setPDFURL:[self.PDFUrlArray objectAtIndex:i]];
        [item setPDFPath:[self.PDFPathArray objectAtIndex:i]];
        [item setPDFName:[[self.PDFPathArray objectAtIndex:i] lastPathComponent]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:item.PDFPath]) {
            UIImage *fImage = [self getFirstPageFromPDF:item.PDFPath];
            [item setPDFFirstImage:fImage];
        }
        else
            [item setPDFFirstImage:nil];
        [originalArray addObject:item];
        [displayArray addObject:item];
        [self performSelectorOnMainThread:@selector(displayTableView) withObject:nil waitUntilDone:NO];
    }
//    displayArray = originalArray;
//    [self performSelectorOnMainThread:@selector(displayTableView) withObject:nil waitUntilDone:YES];
}

- (void)displayTableView{
    [self.courseTableView reloadData];
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


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController setNavigationBarHidden:NO animated:animated];

#endif // DEMO_VIEW_CONTROLLER_PUSH
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController setNavigationBarHidden:YES animated:animated];

#endif // DEMO_VIEW_CONTROLLER_PUSH
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    for (ASIHTTPRequest *request in self.downloadQueue.operations) {
        [request clearDelegatesAndCancel];
    }
    NSLog(@"disappear");
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super viewDidUnload];
    NSLog(@"unload");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // See README
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else
		return YES;
}

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}
*/

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

#pragma mark UIGestureRecognizer methods

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)

	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];

	NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file

	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];

	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];

		readerViewController.delegate = self; // Set the ReaderViewController delegate to self

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

		[self.navigationController pushViewController:readerViewController animated:YES];

#else // present in a modal view controller

		readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;

		[self presentViewController:readerViewController animated:YES completion:NULL];

#endif // DEMO_VIEW_CONTROLLER_PUSH
	}
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

#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int num;
    NSLog(@"display count %d",self.displayArray.count);
    if (self.displayArray.count % ITEM_NUM_IN_ROW == 0) {
        num = self.displayArray.count / ITEM_NUM_IN_ROW;
    }
    else
    {
        num = self.displayArray.count / ITEM_NUM_IN_ROW + 1;
    }
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 280;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d",[indexPath section],[indexPath row]]; //以indexPath来唯一确定cell,不使用完全重用机制
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    int row = indexPath.row;
//    NSLog(@"row--------------------------- %d",row);
    int count = ITEM_NUM_IN_ROW;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        for (int i = 0; i < ITEM_NUM_IN_ROW; i ++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(250 * i + 24, 20, 226, 180)];
            [button setTag:i + 1];
            [button setHidden:YES];
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
            
            [cell.contentView addSubview:button];
            [cell.contentView addSubview:label];
            
        }
        NSLog(@"button count %d",[self.buttonArray count]);
        buttonNumber = [self.buttonArray count];
        displayButtonArray = buttonArray;
        displayProgArray = progressArray;
    } else{
        for (int i = 0 ; i < count; i ++) {
            UIButton *button = (UIButton *)[cell viewWithTag:i + 1];
            MRCircularProgressView *progressView = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
            [progressView setHidden:YES];
//            [progressView setProgress:0];
        }
    }
    for (int i = 0 ; i < count; i ++) {
        UIButton *button = (UIButton *)[cell viewWithTag:i + 1];
        
        UILabel *label = (UILabel *)[cell viewWithTag:i * 10 + 10];
        int index = row * ITEM_NUM_IN_ROW + i;
        if (index >= self.displayArray.count) {
//            NSLog(@"index %d",index);
            [button setHidden:YES];
            [label setHidden:YES];
            continue;
        }
        
        [button setHidden:NO];
//        UIProgressView *progressView = (UIProgressView *)[button viewWithTag:PROGRESS_TAG];
        MRCircularProgressView *progressView = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
        [progressView setHidden:YES];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"index", nil];
        [button setMyDict:dict];
        CoursewareItem *item = [self.displayArray objectAtIndex:index];
        NSString *PDFName = item.PDFName;
        UIImage *PDFFirstImage = item.PDFFirstImage;
//        NSString *PDFPath = item.PDFPath;
        NSString *PDFURL = item.PDFURL;
        for (ASIHTTPRequest *request in self.downloadQueue.operations) {
            if ([request.url isEqual:[NSURL URLWithString:PDFURL]]) {
                request.tag = index;
                
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
    }
    return cell;
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
    UIButton *button = (UIButton *)[buttonArray objectAtIndex:index % buttonNumber];
    
    CoursewareItem *item = [displayArray objectAtIndex:index];
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
        if ([tempRequest.url isEqual:request.url]) {
            return;
        }
    }

    MRCircularProgressView *progress = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
    [progress setHidden:NO];
    progress.progress = 0;
    
    [request setTag:index];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];     //下载完成处理
    [request setDidFailSelector:@selector(requestWentWrong:)];  //下载出错处理
    [request setDownloadProgressDelegate:progress];//设置每个任务的进度条信息
    NSDictionary *myDict = [NSDictionary dictionaryWithObjectsAndKeys:item,@"item", nil];
    [request setMyDict:myDict];
    [[self downloadQueue] addOperation:request];
    
}
//下载所有课件
- (void)downloadAllAction:(id)sender
{
    for (int i = 0; i < [displayArray count]; i ++) {
//        if ([self.downloadQueue operationCount] < buttonNumber) {
        [self downloadPDF:i];
//        }
        
    }
    [self.downloadQueue go];
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
    if (index > [displayArray count]) {
        return;
    }
    
    UIButton *button = [self.buttonArray objectAtIndex:index % buttonNumber];
    NSDictionary *dict = button.myDict;
    index = [(NSNumber *)[dict objectForKey:@"index"] intValue];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [button removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(openCourseware:) forControlEvents:UIControlEventTouchUpInside];
    MRCircularProgressView *progressView = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
    [progressView setHidden:YES];
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
    UIButton *button = [self.buttonArray objectAtIndex:index % buttonNumber];
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
    UIButton *button = [self.buttonArray objectAtIndex:index % buttonNumber];
//    UIProgressView *progressView = (UIProgressView *)[button viewWithTag:PROGRESS_TAG];
    MRCircularProgressView *progressView = (MRCircularProgressView *)[button viewWithTag:PROGRESS_TAG];
    [progressView setHidden:YES];

}

- (void)openCourseware:(id)sender
{
 ////
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = button.myDict;
    int index = [(NSNumber *)[dict objectForKey:@"index"] integerValue];
    CoursewareItem *item = [self.displayArray objectAtIndex:index];
    NSString *filePath = item.PDFPath;

    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
        
        NSString *contents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *NOTEPath = [contents stringByAppendingPathComponent:NOTEFolderName];
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

#pragma serchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
//    NSLog(@"%@",searchText);
//    NSLog(@"%i",[displayArray count]);
    if (searchText!=nil && searchText.length>0) {
        self.displayArray= [NSMutableArray array];
        self.displayButtonArray = [NSMutableArray array];
        for (int i = 0 ; i < [originalArray count];i ++) {
            CoursewareItem *item = [originalArray objectAtIndex:i];
            UIButton *button = [buttonArray objectAtIndex:i % buttonNumber];
            if ([item.PDFName rangeOfString:searchText options:NSCaseInsensitiveSearch].length >0 ) {
                [self.displayArray addObject:item];
                [self.displayButtonArray addObject:button];
//                NSLog(@"%d",[displayArray count]);
            }
        }
        [self.courseTableView reloadData];
    }
    else
    {
        self.displayArray = [NSMutableArray arrayWithArray:originalArray];
        self.displayButtonArray = [NSMutableArray arrayWithArray:buttonArray];
        [self.courseTableView reloadData];
    }
    
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    [self.searchBar resignFirstResponder];
    NSLog(@"click");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self searchBar:self.searchBar textDidChange:nil];
    [self.searchBar resignFirstResponder];
    NSLog(@"cancel");
}



@end
