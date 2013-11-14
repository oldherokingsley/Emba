//
//  CourseMarkViewController.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-11-7.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "CourseMarkViewController.h"
#import "UIButton+associate.h"

#define ITEM_NUM_IN_ROW 4

#define BUTTON_TAG 111111
#define TEXT_FIELD_TAG 222222
#define CLOSE_TAG 333333

@interface CourseMarkViewController ()
{
    BOOL isEdit;
}

@end

@implementation CourseMarkViewController
@synthesize markTableView;
@synthesize document;
@synthesize displayImageArray;
@synthesize displayTextArray;
@synthesize originalImageArray;
@synthesize originalTextArray;
@synthesize bookMarkedArray;
@synthesize imageRect;
@synthesize markToolBar;
@synthesize deleteMarkedArray;
@synthesize pageAngle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithReaderDocument:(ReaderDocument *)object
{
	id marks = nil; // ThumbsViewController object
    
	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
//			updateBookmarked = YES;
//            bookmarked = [NSMutableArray new]; // Bookmarked pages
            
			document = object; // Retain the ReaderDocument object for our use
            imageRect = CGRectMake(8, 8, 0, 0);
            UIImage *image = [self getImageFromPDF:document.fileURL :1];
            CGSize size = image.size;
            pageAngle %= 360;
            if (pageAngle == 90 || pageAngle == 270) {
                size.height = image.size.width;
                size.width = image.size.height;
            }
            if (size.width > size.height) {
                imageRect.size.width = 240;
                imageRect.size.height = size.height * (240 / size.width);
            }else{
                imageRect.size.height = 240;
                imageRect.size.width = size.width * (240 / size.height);
                imageRect.origin.x = (256 - imageRect.size.width) / 2;

            }
			marks = self; // Return an initialized ThumbsViewController object
            //            showBookmarked = YES;
		}
	}
    
	return marks;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    isEdit = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    displayTextArray = [[NSMutableArray alloc]init];
    displayImageArray = [[NSMutableArray alloc]init];
    originalTextArray = [[NSMutableArray alloc]init];
    originalImageArray = [[NSMutableArray alloc]init];
    bookMarkedArray = [[NSMutableArray alloc]init];
    deleteMarkedArray = [[NSMutableArray alloc]init];
    [document.bookmarks enumerateIndexesUsingBlock: // Enumerate
     ^(NSUInteger page, BOOL *stop)
     {
         [bookMarkedArray addObject:[NSNumber numberWithInteger:page]];
     }
     ];
    for (int i = 0 ; i < [bookMarkedArray count]; i ++) {
        int page = [(NSNumber *)[bookMarkedArray objectAtIndex:i] integerValue];
        UIImage *image = [self getImageFromPDF:document.fileURL :page];
        NSLog(@"size %f,%f",image.size.width,image.size.height);
        
        [originalImageArray addObject:image];
        NSLog(@"page %d image %@ string %@",page,image,[document.markTexts objectForKey:[NSString stringWithFormat:@"%d",page]]);
        NSString *text = [document.markTexts objectForKey:[NSString stringWithFormat:@"%d",page]];
        [originalTextArray addObject:text];
        
        [displayTextArray addObject:text];
        
        [displayImageArray addObject:image];
    }
    NSLog(@"finish");
//    displayTextArray = originalTextArray;
//    displayImageArray = originalImageArray;
    
    markTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 1024, 768 - 64)];
    markTableView.delegate = self;
    markTableView.dataSource = self;
    
    [markTableView setSeparatorColor:[UIColor clearColor]];
    [markTableView setAllowsSelection:NO];
    
    [self.view addSubview:markTableView];
    
    markToolBar = [[MarkToolBar alloc]initWithFrame:CGRectMake(0, 0, 1024, 64)];
    markToolBar.delegate = self;
    
    [self.view addSubview:markToolBar];
    NSLog(@"center %f,%f",markTableView.center.x,markTableView.center.y);
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//获取固定某页的pdf image
- (UIImage *)getImageFromPDF:(NSURL *)nsurl :(int)nowPage{
    //	CFStringRef path;
    //	CFURLRef url;
	CGPDFDocumentRef documentRef;
    
//    NSURL *nsurl = [[NSURL alloc]initFileURLWithPath:aFilePath isDirectory:NO];
    
    CFURLRef url = (__bridge CFURLRef)nsurl;
    //    CFURLRef url = CFRetain((__bridge CFTypeRef)(nsurl));
    
    
	documentRef = CGPDFDocumentCreateWithURL(url);
    //	CFRelease(url);
    
	int count = CGPDFDocumentGetNumberOfPages (documentRef);
    if (count == 0) {
		return NULL;
    }
    
    //	return document;
    
    CGPDFPageRef page = CGPDFDocumentGetPage(documentRef, nowPage);
    
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    pageRect.origin = CGPointZero;
//    CGRect mediaBoxRect = cgpdf
    pageAngle = CGPDFPageGetRotationAngle(page);
    NSLog(@"pageAngle %d",pageAngle);
    //开启图片绘制 上下文
    UIGraphicsBeginImageContext(pageRect.size);
    NSLog(@"page size %f %f",pageRect.size.width,pageRect.size.height);
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
    
    CGPDFDocumentRelease(documentRef);
    
    //CGPDFDocumentRelease(document);
    //UIImage *image = [self getUIImageFromPDFPage:0 pdfPage:page];
    //    CGPDFPageRelease(page);
    //CGPDFDocumentRelease(document);
    return image;
    //return image;
    //    CGPDFDocumentRelease(document), document = NULL;
}


#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int num;
    if (self.displayImageArray.count % ITEM_NUM_IN_ROW == 0) {
        num = self.displayImageArray.count / ITEM_NUM_IN_ROW;
    }
    else
    {
        num = self.displayImageArray.count / ITEM_NUM_IN_ROW + 1;
    }
    NSLog(@"num %d",num);

    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 280;
    return imageRect.size.height + 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    int row = indexPath.row;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        for (int i = 0; i < ITEM_NUM_IN_ROW; i ++) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i * 256, 0, 256, 280)];
            [view setHidden:YES];
            [view setTag:i + 1];
            [cell addSubview:view];
            
            UIButton *button = [[UIButton alloc]initWithFrame:imageRect];
            [button setTag:BUTTON_TAG];
            [view addSubview:button];
            
            UITextView *markText = [[UITextView alloc]initWithFrame:CGRectMake(imageRect.origin.x, 8 + imageRect.size.height, imageRect.size.width, 40)];
            [markText setAllowsEditingTextAttributes:NO];
            [markText setTextColor:[UIColor colorWithRed:85.0 / 255 green:85.0 / 255 blue:85.0 / 255 alpha:1.0]];
            [markText setTag:TEXT_FIELD_TAG];
            [markText setTextAlignment:NSTextAlignmentCenter];
            [view addSubview:markText];
            
            UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteButton setImage:[UIImage imageNamed:@"bookmark_edit_delete"] forState:UIControlStateNormal];
            deleteButton.frame = CGRectMake(256 - 30, 0, 28, 28);
            [deleteButton setTag:CLOSE_TAG];
            [deleteButton setHidden:YES];
            [view addSubview:deleteButton];
            
            UIImageView *markImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bookmark_tag"]];
            [markImage setFrame:CGRectMake(20, 4, markImage.frame.size.width, markImage.frame.size.height)];
            [view addSubview:markImage];
                                     
            
            
        }
    }
    for (int i = 0; i < ITEM_NUM_IN_ROW; i ++) {
        UIView *view = [cell viewWithTag:i + 1];
//        UIImageView *imageView = (UIImageView *)[view viewWithTag:0];
        UIButton *button = (UIButton *)[view viewWithTag:BUTTON_TAG];
        UITextView *markText = (UITextView *)[view viewWithTag:TEXT_FIELD_TAG];
        [markText setFont:[UIFont systemFontOfSize:15]];
        UIButton *deleteButton = (UIButton *)[view viewWithTag:CLOSE_TAG];
        int index = row * ITEM_NUM_IN_ROW + i;
        if (index >= [displayImageArray count]) {
            [view setHidden:YES];
            continue;
        }
        [view setHidden:NO];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"index", nil];
        [deleteButton setMyDict:dict];
        [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        if (isEdit) {
            [deleteButton setHidden:NO];
            [markText setEditable:YES];
            
        } else{
            [deleteButton setHidden:YES];
            [markText setEditable:NO];
        }
        
        UIImage *image = [displayImageArray objectAtIndex:index];
//        [imageView setImage:image];
        [button setImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"bookmark_item_bg"] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        [button setMyDict:dict];
        if (!isEdit) {
            [button addTarget:self action:@selector(gotoPageAction:) forControlEvents:UIControlEventTouchUpInside];
        } else{
            [button removeTarget:self action:@selector(gotoPageAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        NSString *text = [displayTextArray objectAtIndex:index];
        [markText setText:text];
    }

    
    return cell;
}

//回到课件浏览页
-(void) gotoPageAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = button.myDict;
    int index = [(NSNumber *)[dict objectForKey:@"index"] integerValue];
    int page = [(NSNumber *)[bookMarkedArray objectAtIndex:index] integerValue];
    [self.delegate courseMarkViewController:self gotoPage:page];
    [self.delegate dismissMarkViewControoler:self];
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma MarkToolBar delegate
- (void)tappedInMarkToolBar:(MarkToolBar *)toolBar back:(UIButton *)button{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate dismissMarkViewControoler:self];
}
-(void)tappedInMarkToolBar:(MarkToolBar *)toolBar cancel:(UIButton *)button{
    [toolBar.finishButton setHidden:YES];
    [toolBar.cancelButton setHidden:YES];
    [toolBar.backButton setHidden:NO];
    [toolBar.editButton setHidden:NO];
    isEdit = NO;
    [deleteMarkedArray removeAllObjects];
    [displayImageArray removeAllObjects];
    [displayTextArray removeAllObjects];
    
//    displayImageArray = originalImageArray;
//    displayTextArray = originalTextArray;
    
    for (int i = 0 ; i < [originalImageArray count]; i ++) {
        [displayImageArray addObject:[originalImageArray objectAtIndex:i]];
        [displayTextArray addObject:[originalTextArray objectAtIndex:i]];
    }
    
    
    [markTableView reloadData];
    
    
}
-(void)tappedInMarkToolBar:(MarkToolBar *)toolBar edit:(UIButton *)button{
    [toolBar.finishButton setHidden:NO];
    [toolBar.cancelButton setHidden:NO];
    [toolBar.backButton setHidden:YES];
    [toolBar.editButton setHidden:YES];
    isEdit = YES;
    [markTableView reloadData];
}
-(void)tappedInMarkToolBar:(MarkToolBar *)toolBar finish:(UIButton *)button{
    [toolBar.finishButton setHidden:YES];
    [toolBar.cancelButton setHidden:YES];
    [toolBar.backButton setHidden:NO];
    [toolBar.editButton setHidden:NO];
    isEdit = NO;
    for (int i = 0; i < [deleteMarkedArray count]; i ++) {
        int index = [(NSNumber *)[deleteMarkedArray objectAtIndex:i] integerValue];
        int page = [(NSNumber *)[bookMarkedArray objectAtIndex:index] integerValue];
        [bookMarkedArray removeObjectAtIndex:index];
        [document.bookmarks removeIndex:page];
        [originalImageArray removeObjectAtIndex:index];
        [originalTextArray removeObjectAtIndex:index];
    }
    [deleteMarkedArray removeAllObjects];
    
    [markTableView reloadData];
    
    
}
-(void)deleteAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = button.myDict;
    int index = [(NSNumber *)[dict objectForKey:@"index"] integerValue];
    [deleteMarkedArray addObject:[NSNumber numberWithInt:index]];
    [displayTextArray removeObjectAtIndex:index];
    [displayImageArray removeObjectAtIndex:index];
    
    [markTableView reloadData];
    
}

@end
