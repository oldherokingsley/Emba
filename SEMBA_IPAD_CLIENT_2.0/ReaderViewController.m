//
//	ReaderViewController.m
//	Reader v2.6.0
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

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "NoteToolbar.h"
#import "CourseMarkViewController.h"
#import <MessageUI/MessageUI.h>
#import "NoteToolDrawerBar.h"

#define kActionSheetColor       100
#define kActionSheetTool        101

#define kPenWidthMin            1.0f
#define kPenWidthMax            30.0f
#define kPenWidthDefault        5.0f
#define kPenAlphaMin            0.100000001490116f
#define kPenAlphaMax            1.0f
#define kPenAlphaDefault        1.0f

#define kMarkAlphaDefault       0.5f

#define SWATCH_VIEW_TAG     111111
#define PEN_VIEW_TAG        222222
#define MARKER_VIEW_TAG     333333
#define ERASER_VIEW_TAG     444444

#define PEN_WIDTH_SLIDER_TAG  111111


@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,
									ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate,NoteToolbarDelegate>
@end

@implementation ReaderViewController
{
	ReaderDocument *document;

	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;
    
    NoteToolbar *noteToolbar;
    
    NoteToolDrawerBar *noteToolDrawerBar;

	NSMutableDictionary *contentViews;

	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL isVisible;
    
    UIImage *noteImage;
    
    UIView *markEditView;
    
    UITextField *markField;
    
    int appearViewTag;
}

#pragma mark Constants

#define PAGING_VIEWS 3

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 64.0f//44.0f
#define PAGEBAR_HEIGHT 46.0f

#define NOTE_HEIGHT 100.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;
@synthesize drawingView;
@synthesize drawNewView;
@synthesize lineWidthSlider;
@synthesize lineAlphaSlider;
@synthesize notePath;
@synthesize eraserWidthView;
@synthesize markerWidthView;
@synthesize penWidthView;
@synthesize swatchView;
#pragma mark Support methods

- (void)updateScrollViewContentSize
{
	NSInteger count = [document.pageCount integerValue];

	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit

	CGFloat contentHeight = theScrollView.bounds.size.height;

	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update the content size

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
		}
	];

	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];

	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
		^(NSUInteger number, BOOL *stop)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;

			viewRect.origin.x += viewRect.size.width; // Next view frame position
		}
	];

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
	NSInteger page = [document.pageNumber integerValue];

	BOOL bookmarked = [document.bookmarks containsIndex:page];

	[mainToolbar setBookmarkState:bookmarked]; // Update
}

- (void)showDocumentPage:(NSInteger)page
{
	if (page != currentPage) // Only if different
	{
        if (drawingView != nil) {
            [drawingView removeFromSuperview];
            drawingView = nil;
        }
        if (noteImage != nil) {
            noteImage = nil;
        }
        if (drawNewView != nil) {
            [drawNewView removeFromSuperview];
            drawNewView = nil;
        }
        
		NSInteger minValue;
        NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;

		if ((page < minPage) || (page > maxPage)) return;

		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);

			if (minValue < minPage)
				{minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
					{minValue--; maxValue--;}
		}

		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];

		NSMutableDictionary *unusedViews = [contentViews mutableCopy];

		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];
            
			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties

				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                
                
                
				[theScrollView addSubview:contentView];
                
                [contentViews setObject:contentView forKey:key];

				contentView.message = self; [newPageSet addIndex:number];
                
                

			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];

				[unusedViews removeObjectForKey:key];
			}
            viewRect.origin.x += viewRect.size.width;
            //初始化以宽为边界
            CGRect targetRect = CGRectInset(contentView.bounds, 4.0, 4.0);
            
            float scale = targetRect.size.width / contentView.theContainerView.bounds.size.width;
            [contentView setZoomScale:scale];
//            NSLog(@"scale %f",scale);
//            [theScrollView setContentOffset:CGPointZero];
//            CGPoint point = CGPointZero;
//            point.y += 10.0;
//            [contentView setContentOffset:point];

			
		}

		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
			^(id key, id object, BOOL *stop)
			{
				[contentViews removeObjectForKey:key];

				ReaderContentView *contentView = object;

				[contentView removeFromSuperview];
			}
		];

		unusedViews = nil; // Release unused views

		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);

		CGPoint contentOffset = CGPointZero;

		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}

		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}

		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;

		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];

			[newPageSet removeIndex:page]; // Remove visible page from set
		}

		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
			^(NSUInteger number, BOOL *stop)
			{
				NSNumber *key = [NSNumber numberWithInteger:number]; // # key

				ReaderContentView *targetView = [contentViews objectForKey:key];

				[targetView showPageThumb:fileURL page:number password:phrase guid:guid];
			}
		];

		newPageSet = nil; // Release new page set

//		[mainPagebar updatePagebar]; // Update the pagebar display

		[self updateToolbarBookmarkIcon]; // Update bookmark
        currentPage = page; // Track current page number
        
        NSNumber *key = [NSNumber numberWithInteger:page]; // # key
        ReaderContentView *newContentView = [contentViews objectForKey:key];
		
        [self addDrawView:newContentView];
	}
}

- (void)addDrawView:(ReaderContentView *)readerContentView{
    if (drawNewView != nil) {
        [drawNewView removeFromSuperview];
        drawNewView = nil;
    }
    if (drawingView != nil) {
        return;
    }
    
//    NSLog(@"pagenumber %d offset %f",[document.pageNumber intValue],theScrollView.contentOffset.x);
    NSString *fileName = [NSString stringWithFormat:@"%d%@",[document.pageNumber intValue], @".plist"];
    NSString *filePath=[[NSString alloc]initWithString:[self.notePath stringByAppendingPathComponent:fileName]];

    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSData *imageData = [[NSData alloc]init];
    
    if (dict != nil) {
        imageData = [dict objectForKey:@"imageData"];
        
        noteImage = [UIImage imageWithData:imageData scale:[[UIScreen mainScreen] scale]];
        
    }
    
    CGRect rect = readerContentView.theContainerView.bounds;
//    CGRect rect2 = readerContentView.bounds;
    self.drawingView = [[ACEDrawingView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) :noteImage];
//    self.delegate = self;
    self.drawingView.delegate = self;
//    [drawingView setUserInteractionEnabled:NO];

    [readerContentView.theContainerView addSubview:drawingView];
    
//    [theScrollView addSubview:drawingView];
}

//开始画
- (void)startDraw{
    [theScrollView setScrollEnabled:NO];

    [drawNewView setUserInteractionEnabled:YES];
    int page = [document.pageNumber intValue];
    
    NSNumber *key = [NSNumber numberWithInteger:page]; // # key
    ReaderContentView *newContentView = [contentViews objectForKey:key];
    newContentView.isNote = YES;
    //    [newContentView setUserInteractionEnabled:NO];
    CGRect rect = newContentView.theContainerView.frame;
    CGRect rect2 = newContentView.bounds;
    
    NSLog(@"frame %f %f %f %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    CGPoint point = theScrollView.bounds.origin;
    CGSize size = theScrollView.bounds.size;
    
    NSLog(@"theScrollView frame %f %f %f %f",point.x,point.y,size.width,size.height);

    CGSize beforeSize;
    if (drawingView != nil) {
        
        beforeSize = drawingView.image.size;
        NSLog(@"remove %f %f",beforeSize.width,beforeSize.height);
        //        NSLog(@"remove %f %f",beforeSize.width,beforeSize.height);

//        NSLog(@"remove %f %f",beforeSize.width,beforeSize.height);
        [drawingView removeFromSuperview];
        drawingView = nil;
    }
    else
        beforeSize = CGSizeZero;
    if (drawNewView != nil) {
        drawNewView.drawTool = currentToolType;
        return;
    }
    
    
//    drawNewView = [[ACEDrawingView alloc]initWithFrame:CGRectMake(theScrollView.contentOffset.x + rect.origin.x + 4.0f, rect.origin.y + 4.0f, rect.size.width, rect.size.height) :noteImage];
    CGSize nowSize =rect.size;
    CGFloat scale = 1;
    if (beforeSize.width != CGSizeZero.width) {
        scale = nowSize.width / beforeSize.width;
    }

    NSLog(@"scale %f %f %f",scale,nowSize.width,beforeSize.width);
    NSLog(@"now scale %f maxScale %f",newContentView.zoomScale,newContentView.maximumZoomScale);
//    NSLog(@"scale %f %f %f",scale,nowSize.width,beforeSize.width);
//    NSLog(@"now scale %f maxScale %f",newContentView.zoomScale,newContentView.maximumZoomScale);
    NSLog(@"scale %f %f %f",scale,nowSize.width,beforeSize.width);
    NSLog(@"now scale %f maxScale %f",newContentView.zoomScale,newContentView.maximumZoomScale);

    UIImage *scaleImage = [self scaleImage:noteImage toScale:scale];
    drawNewView = [[ACEDrawingView alloc]initWithFrame:CGRectMake(theScrollView.contentOffset.x + rect.origin.x + 4.0f - rect2.origin.x - 4.0f, rect.origin.y + 4.0f - rect2.origin.y - 4.0f, rect.size.width, rect.size.height) :scaleImage];
    
    drawNewView.delegate = self;
    drawNewView.lineWidth = self.lineWidthSlider.value;
    drawNewView.lineAlpha = self.lineAlphaSlider.value;
    drawNewView.drawTool = currentToolType;
    [theScrollView addSubview:drawNewView];
    

}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize

{
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
                                
    return scaledImage;
                                
}
- (void)stopDraw{
    
    int page = [document.pageNumber intValue];
    NSNumber *key = [NSNumber numberWithInteger:page]; // # key
    ReaderContentView *newContentView = [contentViews objectForKey:key];
    newContentView.isNote = NO;
//    [newContentView setUserInteractionEnabled:YES];
    
    [theScrollView setScrollEnabled:YES];
    [drawingView setUserInteractionEnabled:NO];
    [drawNewView setUserInteractionEnabled:NO];
}

//保存笔记
- (void)saveDraw{

    NSLog(@"save");
    UIImage *image = drawNewView.image;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    
    
    
    NSString *fileName = [NSString stringWithFormat:@"%d%@",[document.pageNumber intValue], @".plist"];
    
    NSString *filePath=[[NSString alloc]initWithString:[self.notePath stringByAppendingPathComponent:fileName]];
//    NSLog(@"path %@",filePath);
    NSDictionary *noteDateDic = [[NSDictionary alloc]initWithObjectsAndKeys:imageData,@"imageData", nil];
    
    
    
    [noteDateDic writeToFile:filePath atomically:YES];
}

- (void)showDocument:(id)object
{
	[self updateScrollViewContentSize]; // Set content size

	[self showDocumentPage:[document.pageNumber integerValue]];

	document.lastOpen = [NSDate date]; // Update last opened date

	isVisible = YES; // iOS present modal bodge
}

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
	id reader = nil; // ReaderViewController object

	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];

			[object updateProperties]; document = object; // Retain the supplied ReaderDocument object for our use

			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory

			reader = self; // Return an initialized ReaderViewController object
		}
	}

	return reader;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    //笔记初始化
    // set the delegate
    
//    self.drawingView.delegate = self;
    
    // start with a black pen
    
    
    // init the preview image
//    [self.navigationController.navigationBar setHidden:NO];
    
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:@"download_ppt.png"];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

	assert(document != nil); // Must have a valid ReaderDocument

	self.view.backgroundColor = [UIColor grayColor]; // Neutral gray

	CGRect viewRect = self.view.bounds; // View controller's view bounds

	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
	{
		if ([self prefersStatusBarHidden] == NO) // Visible status bar
		{
			viewRect.origin.y += STATUS_HEIGHT;
		}
	}

	theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All

	theScrollView.scrollsToTop = NO;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;

	[self.view addSubview:theScrollView];

	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;
//    toolbarRect.origin.y += 20;
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document]; // At top

	mainToolbar.delegate = self;

	[self.view addSubview:mainToolbar];

	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);

    
	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom

	mainPagebar.delegate = self;

	[self.view addSubview:mainPagebar];
    
    CGRect noteRect = viewRect;
    noteRect.size.height = NOTE_HEIGHT;
    noteRect.origin.y = (viewRect.size.height - NOTE_HEIGHT);

//    NSLog(@"%f %f %f %f",noteRect.origin.x,noteRect.origin.y,noteRect.size.width,noteRect.size.height);
//    noteToolbar = [[NoteToolbar alloc] initWithFrame:CGRectMake(0, 648, 1024, 100)];
//    noteToolbar.delegate = self;
//    [self.view addSubview:noteToolbar];
    
    noteToolDrawerBar = [[NoteToolDrawerBar alloc]initWithFrame:CGRectMake(0, 0, 141, 583) parentView:self.view];
    noteToolDrawerBar.delegate = self;
    [self.view addSubview:noteToolDrawerBar];
    
	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];

	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];

	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
	[self.view addGestureRecognizer:doubleTapTwo];

	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail

	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    [self initSlider];
    
    [self initMarkEditView];
    
    [self initToolView];
    
}

- (void)initToolView{
    int colorNum = 6;
    CGFloat buttonWidth = 60.0f;
    CGFloat buttonHeight = 60.0f;
    CGFloat viewY = 100.0f + 40.0f;
    CGFloat viewX = 160.0f;
    //colorNum * buttonWidth + 4 * 10  + 40
    swatchView = [[UIView alloc]initWithFrame:CGRectMake(0, viewY, colorNum * buttonWidth + 4 * 10  + 40, buttonHeight)];
    [swatchView setBackgroundColor:[UIColor grayColor]];
    NSArray *colorArray = [[NSArray alloc]initWithObjects:[UIColor blackColor],[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor yellowColor],[UIColor whiteColor], nil];
    for (int i = 0; i < colorNum; i ++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20 + (buttonWidth + 10) * i,0, buttonWidth, buttonHeight)];
        [button setTag:i + 1];
        [button setBackgroundColor:[colorArray objectAtIndex:i]];
        [button addTarget:self action:@selector(choColorAction:) forControlEvents:UIControlEventTouchUpInside];
        [swatchView addSubview:button];
    }
    swatchView.hidden = YES;
    [self.view addSubview:swatchView];
    
    CGFloat outButtonHeight = 73.0f;
    
    viewY += (outButtonHeight + 10);
    penWidthView = [[UIView alloc]initWithFrame:CGRectMake(viewX, viewY, 214, 57)];
    UIColor *penBg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ppt_toolbox_pencil_adjust_bg"]];
    [penWidthView setBackgroundColor:penBg];
    UISlider *penWidthSlider = [[UISlider alloc]initWithFrame:CGRectMake(15, 12, 185, 29)];
//    [penWidthSlider setTintColor:[UIColor redColor]];
    [penWidthSlider setMaximumTrackImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_bar_active"] forState:UIControlStateNormal];
    [penWidthSlider setMinimumTrackImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_bar_inactive"] forState:UIControlStateNormal];
//    [penWidthSlider setThumbImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_handle"] forState:UIControlStateNormal];
    
    [penWidthSlider setMinimumValue:kPenWidthMin];
    [penWidthSlider setMaximumValue:kPenWidthMax];
    [penWidthSlider addTarget:self action:@selector(widthChange:) forControlEvents:UIControlEventValueChanged];
    [penWidthSlider setValue:kPenWidthDefault];
    penWidthSlider.backgroundColor = [UIColor clearColor];
    [penWidthSlider setTag:PEN_WIDTH_SLIDER_TAG];
    [penWidthView addSubview:penWidthSlider];
    penWidthView.hidden = YES;
    [self.view addSubview:penWidthView];
    
    viewY += (outButtonHeight + 10);
    markerWidthView = [[UIView alloc]initWithFrame:CGRectMake(viewX, viewY, 214, 57)];
    UIColor *markerBg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ppt_toolbox_pencil_adjust_bg"]];
    [markerWidthView setBackgroundColor:markerBg];
    UISlider *markerWidthSlider = [[UISlider alloc]initWithFrame:CGRectMake(15, 12, 185, 29)];
    [markerWidthSlider setMaximumTrackImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_bar_active"] forState:UIControlStateNormal];
    [markerWidthSlider setMinimumTrackImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_bar_inactive"] forState:UIControlStateNormal];
//    [markerWidthSlider setThumbImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_handle"] forState:UIControlStateNormal];
    [markerWidthSlider setMinimumValue:kPenWidthMin];
    [markerWidthSlider setMaximumValue:kPenWidthMax];
    [markerWidthSlider addTarget:self action:@selector(widthChange:) forControlEvents:UIControlEventValueChanged];
    [markerWidthSlider setValue:kPenWidthDefault];
    [markerWidthSlider setBackgroundColor:[UIColor clearColor]];
    [markerWidthSlider setTag:PEN_WIDTH_SLIDER_TAG];
    [markerWidthView addSubview:markerWidthSlider];
    markerWidthView.hidden = YES;
    [self.view addSubview:markerWidthView];
    
    viewY += (outButtonHeight + 10 + 5);
    eraserWidthView = [[UIView alloc]initWithFrame:CGRectMake(viewX, viewY, 310, 58)];
    UIColor *eraserBg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_bg"]];
    [eraserWidthView setBackgroundColor:eraserBg];
    UISlider *eraserWidthSlider = [[UISlider alloc]initWithFrame:CGRectMake(15, 12, 185, 29)];
    [eraserWidthSlider setMaximumTrackImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_bar_active"] forState:UIControlStateNormal];
    [eraserWidthSlider setMinimumTrackImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_bar_inactive"] forState:UIControlStateNormal];
//    [eraserWidthSlider setThumbImage:[UIImage imageNamed:@"ppt_toolbox_eraser_adjust_handle"] forState:UIControlStateNormal];
    [eraserWidthSlider setMinimumValue:kPenWidthMin];
    [eraserWidthSlider setMaximumValue:kPenWidthMax];
    [eraserWidthSlider addTarget:self action:@selector(widthChange:) forControlEvents:UIControlEventValueChanged];
    [eraserWidthSlider setValue:kPenWidthDefault];
    [eraserWidthSlider setBackgroundColor:[UIColor clearColor]];
    [eraserWidthSlider setTag:PEN_WIDTH_SLIDER_TAG];
    eraserWidthView.hidden = YES;
    [eraserWidthView addSubview:eraserWidthSlider];
    
    UIButton *clearButton = [[UIButton alloc]initWithFrame:CGRectMake(210, 12, 81, 34)];
    [clearButton setBackgroundImage:[UIImage imageNamed:@"ppt_toolbox_eraser_delete_all"] forState:UIControlStateNormal];
    [clearButton setTitle:@"清空全部" forState:UIControlStateNormal];
//    [clearButton setTintColor:[UIColor redColor]];
    [clearButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    [eraserWidthView addSubview:clearButton];
    [self.view addSubview:eraserWidthView];
    
}

- (void)swatchDisappear:(UIView *)view{
    CGRect rect = view.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    rect.size.width = 0;
    view.frame = rect;
    [UIView commitAnimations];
}
- (void)swatchAppear:(UIView *)view{
    CGRect rect = view.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    rect.size.width = 6 * 60 + 4 * 10 + 40;
    view.frame = rect;
    [UIView commitAnimations];
}
- (void)viewDisappear:(UIView *)view{
    if (view.hidden == NO)
	{
//        NSLog(@"hide");
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             view.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             view.hidden = YES;
         }
         ];
	}
}
- (void)viewAppear:(UIView *)view{
    if (view.hidden == YES)
	{
//        NSLog(@"show");
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             view.hidden = NO;
             view.alpha = 1.0f;
         }
                         completion:NULL
         ];
	}

}
- (void)clearAction:(id)button{
    [self.drawNewView clear];
}

- (void)choColorAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    UIColor *color = button.backgroundColor;
    UIButton *originalButton = [noteToolDrawerBar.buttonArray objectAtIndex:0];
    [originalButton setBackgroundColor:color];
    self.drawNewView.lineColor = color;
    [self viewDisappear:swatchView];
}

//初始化书签编辑框
- (void)initMarkEditView{
    UIImage *image = [UIImage imageNamed:@"ppt_popup_bg"];
    markEditView = [[UIView alloc]initWithFrame:CGRectMake((1024 - image.size.width) / 2,(768 - image.size.height) / 2, image.size.width, image.size.height)];
    UIColor *background = [UIColor colorWithPatternImage:image];
    [markEditView setBackgroundColor:background];
    [markEditView setAlpha:0.0f];
    [self.view addSubview:markEditView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(143, 45, 160, 40)];
    [label setText:@"添加成功"];
    [label setTextColor:[UIColor colorWithRed:216.0 / 255 green:65.0 / 255 blue:87.0 / 255 alpha:1.0]];
    [label setFont:[UIFont systemFontOfSize:36]];
    [markEditView addSubview:label];
    
    markField = [[UITextField alloc]initWithFrame:CGRectMake(36, 120, image.size.width - 36 * 2, 47)];
    [markField setBackground:[UIImage imageNamed:@"ppt_popup_editbookmarkname"]];
    [markField setPlaceholder:@"为该书签页命名"];
    markField.delegate = self;
    [markEditView addSubview:markField];

    int button_height = 60;
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sureButton setFrame:CGRectMake(0, markEditView.frame.size.height - button_height, image.size.width / 2, button_height)];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTintColor:[UIColor colorWithRed:69.0 / 255 green:69.0 / 255 blue:69.0 / 255 alpha:1.0]];
    [sureButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [sureButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [markEditView addSubview:sureButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:CGRectMake(image.size.width / 2, markEditView.frame.size.height - button_height, image.size.width / 2, button_height)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor colorWithRed:69.0 / 255 green:69.0 / 255 blue:69.0 / 255 alpha:1.0]];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [markEditView addSubview:cancelButton];
    
    
}
//书签编辑确定按钮
-(void)sureAction:(id)sender
{
    [self showMarkEditView:markEditView];
    NSString *text = markField.text;
    int page = [document.pageNumber intValue];
//    NSLog(@"")
    if (text == nil || [text isEqualToString:@""]) {
        text = [NSString stringWithFormat:@"Page %d",page];
    }
    [document.markTexts setObject:text forKey:[NSString stringWithFormat:@"%d",page]];
}

//书签编辑取消按钮
-(void)cancelAction:(id)sender
{
    [self showMarkEditView:markEditView];
    NSString *text = markField.text;
    int page = [document.pageNumber intValue];
    text = [NSString stringWithFormat:@"Page %d",page];
    [document.markTexts setObject:text forKey:[NSString stringWithFormat:@"%d",page]];

}

//初始化滑动条
-(void)initSlider{
    //Init Fader slider UI, set listener method and Transform it to vertical
    
    //宽度滑动条
    self.lineWidthSlider = [[UISlider alloc]initWithFrame:CGRectMake(100, 500, 150, 29)];
    [self.lineWidthSlider setMinimumValue:kPenWidthMin];
    [self.lineWidthSlider setMaximumValue:kPenWidthMax];
    [self.lineWidthSlider addTarget:self action:@selector(widthChange:) forControlEvents:UIControlEventValueChanged];
    
    self.lineWidthSlider.backgroundColor = [UIColor clearColor];
    
    /*
    UIImage *stetchTrack = [[UIImage imageNamed:@"faderTrack.png"]
                            stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    [lineWidthSlider setThumbImage: [UIImage imageNamed:@"faderKey.png"] forState:UIControlStateNormal];
    [lineWidthSlider setMinimumTrackImage:stetchTrack forState:UIControlStateNormal];
    [lineWidthSlider setMaximumTrackImage:stetchTrack forState:UIControlStateNormal];
     */
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
    self.lineWidthSlider.transform = trans;
    self.lineWidthSlider.value = kPenWidthDefault;
    self.lineWidthSlider.hidden = YES;
    [self.view addSubview:self.lineWidthSlider];
    
    //透明度滑动条
    self.lineAlphaSlider = [[UISlider alloc]initWithFrame:CGRectMake(1024 - 100, 500, 150, 20)];
    [self.lineAlphaSlider setMinimumValue:kPenAlphaMin];
    [self.lineAlphaSlider setMaximumValue:kPenAlphaMax];
    [self.lineAlphaSlider addTarget:self action:@selector(alphaChange:) forControlEvents:UIControlEventValueChanged];
    self.lineAlphaSlider.backgroundColor = [UIColor clearColor];
    
    trans = CGAffineTransformMakeRotation(M_PI * -0.5);
    self.lineAlphaSlider.transform = trans;
    self.lineAlphaSlider.value = kPenAlphaDefault;
    self.lineAlphaSlider.hidden = YES;
    [self.view addSubview:self.lineAlphaSlider];
    
}
- (void)widthChange:(UISlider *)sender{
    self.drawNewView.lineWidth = sender.value;
//    NSLog(@"%f",sender.value);
}
- (void)alphaChange:(UISlider *)sender{
    self.drawNewView.lineAlpha = sender.value;
}



#pragma Notebar delegate

- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceColor:(UIButton *)button{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Selet a color"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Black", @"Red", @"Green", @"Blue", nil];
    
    [actionSheet setTag:kActionSheetColor];
    [actionSheet showInView:self.view];
}
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceWidth:(UIButton *)button{
    self.lineWidthSlider.hidden = !self.lineWidthSlider.hidden;
    [self.navigationController.navigationBar setHidden:NO];
}
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choicePen:(UIButton *)button{
    
    [self stopDraw];
    [self saveDraw];
    int page = [document.pageNumber intValue];
    NSNumber *key = [NSNumber numberWithInteger:page]; // # key
    ReaderContentView *newContentView = [contentViews objectForKey:key];
    [self addDrawView:newContentView];
}
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceBrush:(UIButton *)button{
    self.lineAlphaSlider.hidden = !self.lineAlphaSlider.hidden;
}

- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceErase:(UIButton *)button{
//    NSLog(@"eraser");
    currentToolType = ACEDrawingToolTypeEraser;
    [self startDraw];
}
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar undoAction:(UIButton *)button{
    [self.drawNewView undoLatestStep];
}
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar redoAction:(UIButton *)button{
    [self.drawNewView redoLatestStep];
}
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar clearAction:(UIButton *)button{
    [self.drawNewView clear];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	mainToolbar = nil; mainPagebar = nil;

	theScrollView = nil; contentViews = nil; lastHideTime = nil;

	lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge

	[self updateScrollViewContentViews]; // Update content views

	lastAppearSize = CGSizeZero; // Reset view size tracking
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (isVisible == NO) return; // iOS present modal bodge

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

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [mainPagebar updatePagebar];
    if (markEditView.alpha == 1) {
        [self showMarkEditView:markEditView];
    }

	__block NSInteger page = 0;
    

	CGFloat contentOffsetX = scrollView.contentOffset.x;

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object;

			if (contentView.frame.origin.x == contentOffsetX)
			{
				page = contentView.tag; *stop = YES;
			}
		}
	];

	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self showDocumentPage:theScrollView.tag]; // Show page

	theScrollView.tag = 0; // Clear page number tag
    [mainPagebar updatePagebar];
    if (markEditView.alpha == 1) {
        [self showMarkEditView:markEditView];
    }
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != minPage))
		{
            
//            [self saveDraw];
//            [self stopDraw];
            if (noteToolDrawerBar.center.x == noteToolDrawerBar.openPoint.x) {
                [noteToolDrawerBar openOrCloseToolBar];
            }
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x -= theScrollView.bounds.size.width; // -= 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
    
}

- (void)incrementPageNumber
{
    
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != maxPage))
		{
            if (noteToolDrawerBar.center.x == noteToolDrawerBar.openPoint.x) {
                [noteToolDrawerBar openOrCloseToolBar];
            }
            
//            [self saveDraw];
//            [self stopDraw];
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x += theScrollView.bounds.size.width; // += 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page + 1); // Increment page number
		}
	}
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
        if (markEditView.alpha == 1) {
            [self showMarkEditView:markEditView];
        }
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area

		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
//            NSLog(@"in");
			NSInteger page = [document.pageNumber integerValue]; // Current page #

			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			id target = [targetView processSingleTap:recognizer]; // Target

			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object

					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string

						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [NSString stringWithFormat:@"http://%@", www];

							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}

					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
						#ifdef DEBUG
							NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
						#endif
					}
				}
				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger value = [target integerValue]; // Number

						[self showDocumentPage:value]; // Show the page
                        
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES)
                        || (noteToolDrawerBar.hidden == YES))
					{
						[mainToolbar showToolbar];
                        [mainPagebar showPagebar]; // Show
                        [noteToolDrawerBar showNoteToolDrawerBar];
//                        [self viewAppear:penWidthView];
//                        [self viewAppear:swatchView];
//                        [self viewAppear:eraserWidthView];
//                        [self viewAppear:markerWidthView];
					}
                    
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
       
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
//             NSLog(@"out");
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
//             NSLog(@"out");
			[self decrementPageNumber]; return;
		}
        
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
//        NSLog(@"two");
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);

		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #

			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					[targetView zoomIncrement]; break;
				}

				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO)
        || (noteToolDrawerBar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		[mainToolbar hideToolbar];
        [mainPagebar hidePagebar]; // Hide
        [noteToolDrawerBar hideNoteToolDrawerBar];
        [self viewDisappear:markerWidthView];
        [self viewDisappear:eraserWidthView];
        [self viewDisappear:swatchView];
        [self viewDisappear:penWidthView];

		lastHideTime = [NSDate date];
	}
    if (markEditView.alpha == 1) {
        [self showMarkEditView:markEditView];
    }
}


#pragma mark ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option

	[document saveReaderDocument]; // Save any ReaderDocument object changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache

	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
        
	}
	else // We have a "Delegate must respond to -dismissReaderViewController: error"
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}

#endif // end of READER_STANDALONE Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
    
    CourseMarkViewController *courseMarkViewController = [[CourseMarkViewController alloc]initWithReaderDocument:document];
    courseMarkViewController.delegate = self;
    
    [self presentViewController:courseMarkViewController animated:YES completion:nil];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
#if (READER_ENABLE_PRINT == TRUE) // Option

	Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

	if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
	{
		NSURL *fileURL = document.fileURL; // Document file URL

		printInteraction = [printInteractionController sharedPrintController];

		if ([printInteractionController canPrintURL:fileURL] == YES) // Check first
		{
			UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];

			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;

			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;

			if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
			else // Presume UIUserInterfaceIdiomPhone
			{
				[printInteraction presentAnimated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
		}
	}

#endif // end of READER_ENABLE_PRINT Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
#if (READER_ENABLE_MAIL == TRUE) // Option

	if ([MFMailComposeViewController canSendMail] == NO) return;

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	unsigned long long fileSize = [document.fileSize unsignedLongLongValue];

	if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
	{
		NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName; // Document

		NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];

		if (attachment != nil) // Ensure that we have valid document file attachment data
		{
			MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];

			[mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];

			[mailComposer setSubject:fileName]; // Use the document file name for the subject

			mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;

			mailComposer.mailComposeDelegate = self; // Set the delegate

			[self presentViewController:mailComposer animated:YES completion:NULL];
		}
	}

#endif // end of READER_ENABLE_MAIL Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
    
    
	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	NSInteger page = [document.pageNumber integerValue];

	if ([document.bookmarks containsIndex:page]) // Remove bookmark
	{
		[mainToolbar setBookmarkState:NO];
        [document.bookmarks removeIndex:page];
        
	}
	else // Add the bookmarked page index to the bookmarks set
	{
        [self showMarkEditView:markEditView];
		[mainToolbar setBookmarkState:YES];
        [document.bookmarks addIndex:page];
        NSString *text = [NSString stringWithFormat:@"Page %d",page];
        [document.markTexts setObject:text forKey:[NSString stringWithFormat:@"%d",page]];
	}
    
}
- (void)showMarkEditView:(UIView *)view
{
    if (view.alpha == 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        CGRect rect = view.frame;
        rect.origin.y -= 20;
        view.frame = rect;
        view.alpha = 1.0;
        [UIView commitAnimations];
        [markField setText:nil];
    }
    else if (view.alpha == 1){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect rect = view.frame;
        rect.origin.y += 20;
        view.frame = rect;
        view.alpha = 0.0;
        [UIView commitAnimations];
        
        
    }
}


#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	#ifdef DEBUG
		if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
	#endif

	[self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}

#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
	[self updateToolbarBookmarkIcon]; // Update bookmark icon

	[self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
    [self showDocumentPage:page]; // Show the page
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    if (noteToolDrawerBar.center.x == noteToolDrawerBar.openPoint.x) {
        [noteToolDrawerBar openOrCloseToolBar];
    }
	[self showDocumentPage:page]; // Show the page
}
- (void)pagebar:(ReaderMainPagebar *)pagebar leftAction:(UIButton *)button{
    [self decrementPageNumber];
}
- (void)pagebar:(ReaderMainPagebar *)pagebar rightAction:(UIButton *)button{
    [self incrementPageNumber];
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}


#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        if (actionSheet.tag == kActionSheetColor) {
            
            currentToolType = ACEDrawingToolTypePen;
            [self startDraw];
//            self.colorButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawNewView.lineColor = [UIColor blackColor];
                    break;
                    
                case 1:
                    self.drawNewView.lineColor = [UIColor redColor];
                    break;
                    
                case 2:
                    self.drawNewView.lineColor = [UIColor greenColor];
                    break;
                    
                case 3:
                    self.drawNewView.lineColor = [UIColor blueColor];
                    break;
            }
            
        } else {
            
//            self.toolButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawingView.drawTool = ACEDrawingToolTypePen;
                    break;
                    
                case 1:
                    self.drawingView.drawTool = ACEDrawingToolTypeLine;
                    break;
                    
                case 2:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleStroke;
                    break;
                    
                case 3:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleFill;
                    break;
                    
                case 4:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseStroke;
                    break;
                    
                case 5:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseFill;
                    break;
                    
                case 6:
                    self.drawingView.drawTool = ACEDrawingToolTypeEraser;
                    break;
            }
            
            // if eraser, disable color and alpha selection
//            self.colorButton.enabled = self.alphaButton.enabled = buttonIndex != 6;
        }
    }
}

#pragma CourseMarkView delegate
- (void) courseMarkViewController:(CourseMarkViewController *)viewController gotoPage:(NSInteger)page
{
    [self showDocumentPage:page];
}
-(void) dismissMarkViewControoler:(CourseMarkViewController *)viewController
{
    [self updateToolbarBookmarkIcon]; // Update bookmark icon
    
	[self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}

#pragma NoteToolDrawerBar delegate
- (void)tappedInNoteToolDrawerBar:(NoteToolDrawerBar *)toolDrawerBar toolAction:(UIButton *)button{
//    NSLog(@"tag %d",button.tag);
//    swatchView.hidden = YES;
//    penWidthView.hidden = YES;
//    eraserWidthView.hidden = YES;
//    markerWidthView.hidden = YES;
    [self viewDisappear:swatchView];
    [self viewDisappear:penWidthView];
    [self viewDisappear:eraserWidthView];
    [self viewDisappear:markerWidthView];
    switch (button.tag) {
        case 1:         //选择颜色
//            if (button.selected) {
//                swatchView.hidden = NO;
//                [self swatchAppear:swatchView];
                [self viewAppear:swatchView];
//            } else{
//                swatchView.hidden = YES;
//                [self swatchDisappear:swatchView];
//                [self viewDisappear:swatchView];
//            }
            
            break;
        case 2:         //选择钢笔
            if (button.selected) {
                currentToolType = ACEDrawingToolTypePen;
                drawNewView.drawTool = ACEDrawingToolTypePen;
                drawNewView.lineAlpha = 1.0f;
                UISlider *penWidthSlider = (UISlider *)[penWidthView viewWithTag:PEN_WIDTH_SLIDER_TAG];
                drawNewView.lineWidth = penWidthSlider.value;
                [self viewAppear:penWidthView];
            } else{

                [self viewDisappear:penWidthView];
            }
            break;
        case 3:         //选择荧光笔
            if (button.selected) {
                currentToolType = ACEDrawingToolTypePen;
                drawNewView.drawTool = ACEDrawingToolTypePen;
                drawNewView.lineAlpha = kMarkAlphaDefault;
                UISlider *markWidthSlider = (UISlider *)[markerWidthView viewWithTag:PEN_WIDTH_SLIDER_TAG];
                drawNewView.lineWidth = markWidthSlider.value;
                [self viewAppear:markerWidthView];
            } else{
                [self viewDisappear:markerWidthView];
            }
            break;
        case 4:         //选择橡皮
            if (button.selected) {
                if (currentToolType == ACEDrawingToolTypePen) {
                    UISlider *eraserWidthSlider = (UISlider *)[eraserWidthView viewWithTag:PEN_WIDTH_SLIDER_TAG];
                    if (drawNewView.lineAlpha == 1.0f) {
                        UISlider *penWidthSlider = (UISlider *)[penWidthView viewWithTag:PEN_WIDTH_SLIDER_TAG];
                        [eraserWidthSlider setValue:penWidthSlider.value];
                    } else if (drawNewView.lineAlpha == kMarkAlphaDefault){
                        UISlider *markWidthSlider = (UISlider *)[markerWidthView viewWithTag:PEN_WIDTH_SLIDER_TAG];
                        [eraserWidthSlider setValue:markWidthSlider.value];
                    }
                }
                                currentToolType = ACEDrawingToolTypeEraser;
                drawNewView.drawTool = ACEDrawingToolTypeEraser;
//                eraserWidthView.hidden = NO;
                [self viewAppear:eraserWidthView];
            } else{
//                eraserWidthView.hidden = YES;
                [self viewDisappear:eraserWidthView];
            }
            break;
        case 5:         //选择相机
            
            break;
        case 6:         //选择录音
            
            break;
        default:
            break;
    }
}
//打开drawer
- (void)drawerOpen:(NoteToolDrawerBar *)toolDrawerBar{
    currentToolType = ACEDrawingToolTypePen;
    [self startDraw];
}
//关闭drawer
-(void)drawerClose:(NoteToolDrawerBar *)toolDrawerBar{
    [self viewDisappear:markerWidthView];
    [self viewDisappear:penWidthView];
    [self viewDisappear:swatchView];
    [self viewDisappear:eraserWidthView];
    [noteToolDrawerBar closeAllButton];
    [self stopDraw];
    [self saveDraw];
    int page = [document.pageNumber intValue];
    NSNumber *key = [NSNumber numberWithInteger:page]; // # key
    ReaderContentView *newContentView = [contentViews objectForKey:key];
    [self addDrawView:newContentView];
}
#pragma ACEDrawView delegate
- (void)intoDrawState:(ACEDrawingView *)view{
    [noteToolDrawerBar hideNoteToolDrawerBar];
    [mainPagebar hidePagebar];
    [mainToolbar hideToolbar];
    if (!swatchView.hidden) {
        appearViewTag = SWATCH_VIEW_TAG;
    }
    if (!penWidthView.hidden) {
        appearViewTag = PEN_VIEW_TAG;
    }
    if (!markerWidthView.hidden) {
        appearViewTag = MARKER_VIEW_TAG;
    }
    if (!eraserWidthView.hidden) {
        appearViewTag = ERASER_VIEW_TAG;
    }
    [self viewDisappear:markerWidthView];
    [self viewDisappear:penWidthView];
    [self viewDisappear:swatchView];
    [self viewDisappear:eraserWidthView];
}

- (void)cancelDrawState:(ACEDrawingView *)view{
    [noteToolDrawerBar showNoteToolDrawerBar];
    [mainToolbar showToolbar];
    [mainPagebar showPagebar];
    if (appearViewTag == SWATCH_VIEW_TAG) {
        [self viewAppear:swatchView];
    }
    if (appearViewTag == PEN_VIEW_TAG) {
        [self viewAppear:penWidthView];
    }
    if (appearViewTag == MARKER_VIEW_TAG) {
        [self viewAppear:markerWidthView];
    }
    if (appearViewTag ==ERASER_VIEW_TAG) {
        [self viewAppear:eraserWidthView];
    }
}
#pragma Mark UITextFieldDelegate
// 下面两个方法是为了防止TextView让键盘挡住的方法
/*
 开始编辑UITextView的方法
 */
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect curFrame = markEditView.frame;
    [UIView animateWithDuration:0.3f animations:^{
        markEditView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y - 200, curFrame.size.width, curFrame.size.height);
    }];
}

/**
 结束编辑UITextView的方法，让原来的界面还原高度
 */
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    
    CGRect curFrame = markEditView.frame;
    [UIView beginAnimations:@"drogDownKeyBoard" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    markEditView.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y + 200, curFrame.size.width, curFrame.size.height);
    [UIView commitAnimations];
}


@end
