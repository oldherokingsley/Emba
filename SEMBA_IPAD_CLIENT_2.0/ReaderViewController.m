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

#import <MessageUI/MessageUI.h>

#define kActionSheetColor       100
#define kActionSheetTool        101

#define kPenWidthMin            1.0f
#define kPenWidthMax            30.0f
#define kPenWidthDefault        5.0f
#define kPenAlphaMin            0.100000001490116f
#define kPenAlphaMax            1.0f
#define kPenAlphaDefault        1.0f


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

	NSMutableDictionary *contentViews;

	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL isVisible;
    
    UIImage *noteImage;
    
    UIView *markEditView;
    
    UITextField *markField;
}

#pragma mark Constants

#define PAGING_VIEWS 3

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define NOTE_HEIGHT 100.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;
@synthesize drawingView;
@synthesize drawNewView;
@synthesize lineWidthSlider;
@synthesize lineAlphaSlider;
@synthesize notePath;
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
            
            //初始化以宽为边界
            CGRect targetRect = CGRectInset(contentView.bounds, 4.0, 4.0);
            
            float scale = targetRect.size.width / contentView.theContainerView.bounds.size.width;
            [contentView setZoomScale:scale];
            NSLog(@"scale %f",scale);
//            [theScrollView setContentOffset:CGPointZero];
            CGPoint point = CGPointZero;
            point.y += 10.0;
            [contentView setContentOffset:point];

			viewRect.origin.x += viewRect.size.width;
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
    
    NSLog(@"pagenumber %d offset %f",[document.pageNumber intValue],theScrollView.contentOffset.x);
    NSString *fileName = [NSString stringWithFormat:@"%d%@",[document.pageNumber intValue], @".plist"];
    NSString *filePath=[[NSString alloc]initWithString:[self.notePath stringByAppendingPathComponent:fileName]];

    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSData *imageData = [[NSData alloc]init];
    
    if (dict != nil) {
        imageData = [dict objectForKey:@"imageData"];
        
        noteImage = [UIImage imageWithData:imageData scale:[[UIScreen mainScreen] scale]];
        
    }
    
    CGRect rect = readerContentView.theContainerView.bounds;
    self.drawingView = [[ACEDrawingView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) :noteImage];
//    [drawingView setUserInteractionEnabled:NO];

    [readerContentView.theContainerView addSubview:drawingView];
    
//    [theScrollView addSubview:drawingView];
}

//开始画
- (void)startDraw{
    [theScrollView setScrollEnabled:NO];

    [drawNewView setUserInteractionEnabled:YES];
    
    if (drawingView != nil) {
        [drawingView removeFromSuperview];
        drawingView = nil;
    }
    if (drawNewView != nil) {
        drawNewView.drawTool = currentToolType;
        return;
    }
    
    int page = [document.pageNumber intValue];
    
    NSNumber *key = [NSNumber numberWithInteger:page]; // # key
    ReaderContentView *newContentView = [contentViews objectForKey:key];
    newContentView.isNote = YES;
//    [newContentView setUserInteractionEnabled:NO];
    CGRect rect = newContentView.theContainerView.frame;
    drawNewView = [[ACEDrawingView alloc]initWithFrame:CGRectMake(theScrollView.contentOffset.x + rect.origin.x + 4.0f, rect.origin.y + 4.0f, rect.size.width, rect.size.height) :noteImage];
    drawNewView.lineWidth = self.lineWidthSlider.value;
    drawNewView.lineAlpha = self.lineAlphaSlider.value;
    drawNewView.drawTool = currentToolType;
    [theScrollView addSubview:drawNewView];
    

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

    UIImage *image = drawNewView.image;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    
    
    
    NSString *fileName = [NSString stringWithFormat:@"%d%@",[document.pageNumber intValue], @".plist"];
    
    NSString *filePath=[[NSString alloc]initWithString:[self.notePath stringByAppendingPathComponent:fileName]];
    NSLog(@"path %@",filePath);
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

	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document]; // At top

	mainToolbar.delegate = self;

	[self.view addSubview:mainToolbar];

	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);

    
//	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom

//	mainPagebar.delegate = self;

//	[self.view addSubview:mainPagebar];
    
    CGRect noteRect = viewRect;
    noteRect.size.height = NOTE_HEIGHT;
    noteRect.origin.y = (viewRect.size.height - NOTE_HEIGHT);

    NSLog(@"%f %f %f %f",noteRect.origin.x,noteRect.origin.y,noteRect.size.width,noteRect.size.height);
    noteToolbar = [[NoteToolbar alloc] initWithFrame:CGRectMake(0, 648, 1024, 100)];
    noteToolbar.delegate = self;
    [self.view addSubview:noteToolbar];
    
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
    
}
//初始化书签编辑框
- (void)initMarkEditView{
    markEditView = [[UIView alloc]initWithFrame:CGRectMake(1024 - 300, 44 + 40, 200, 100)];
    [markEditView setBackgroundColor:[UIColor redColor]];
    [markEditView setAlpha:0.0f];
    [self.view addSubview:markEditView];
    
    markField = [[UITextField alloc]initWithFrame:CGRectMake((markEditView.bounds.size.width - 150) / 2, 20, 150, 50)];
    [markField setPlaceholder:@"请输入书签名称"];
    [markEditView addSubview:markField];

    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sureButton setFrame:CGRectMake(20, markField.frame.origin.y + 30, 70, 50)];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [markEditView addSubview:sureButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:CGRectMake(markEditView.bounds.size.width - 50 - 70, markField.frame.origin.y + 30, 70, 50)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [markEditView addSubview:cancelButton];
    
    
}
//书签编辑确定按钮
-(void)sureAction:(id)sender
{
    [self showMarkEditView:markEditView];
    NSString *text = markField.text;
    int page = [document.pageNumber intValue];
    [document.markTexts setObject:text forKey:[NSString stringWithFormat:@"%d",page]];
}

//书签编辑取消按钮
-(void)cancelAction:(id)sender
{
    [self showMarkEditView:markEditView];
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
    NSLog(@"%f",sender.value);
}
- (void)alphaChange:(UISlider *)sender{
    self.drawNewView.lineAlpha = sender.value;
}



#pragma Notebar delegate

- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceColor:(UIButton *)button{
    NSLog(@"pen");
//    currentToolType = ACEDrawingToolTypePen;
//    [self startDraw];
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
    NSLog(@"eraser");
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
            
            [self saveDraw];
            [self stopDraw];
            
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
            [self saveDraw];
            [self stopDraw];
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
        
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area

		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
            NSLog(@"in");
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
					if ((mainToolbar.hidden == YES) || noteToolbar.hidden == YES /*(mainPagebar.hidden == YES)*/)
					{
						[mainToolbar showToolbar]; [noteToolbar showNoteToolbar]; //[mainPagebar showPagebar]; // Show
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
             NSLog(@"out");
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
             NSLog(@"out");
			[self decrementPageNumber]; return;
		}
        
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
        NSLog(@"two");
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
	if ((mainToolbar.hidden == NO) || noteToolbar.hidden == NO /*(mainPagebar.hidden == NO)*/)
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		[mainToolbar hideToolbar]; [noteToolbar hideNoteToolbar];//[mainPagebar hidePagebar]; // Hide

		lastHideTime = [NSDate date];
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
	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];

	thumbsViewController.delegate = self;
    thumbsViewController.title = self.title;

	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;

	[self presentViewController:thumbsViewController animated:YES completion:nil];
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
    
    [self showMarkEditView:markEditView];
	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	NSInteger page = [document.pageNumber integerValue];

	if ([document.bookmarks containsIndex:page]) // Remove bookmark
	{
		[mainToolbar setBookmarkState:NO];
        [document.bookmarks removeIndex:page];
        
	}
	else // Add the bookmarked page index to the bookmarks set
	{
		[mainToolbar setBookmarkState:YES];
        [document.bookmarks addIndex:page];
        
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
    }
    else if (view.alpha == 1){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
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
	[self showDocumentPage:page]; // Show the page
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


@end
