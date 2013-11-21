//
//  NoteToolbar.m
//  Reader
//
//  Created by yaodd on 13-10-20.
//
//

#import "NoteToolbar.h"

#pragma mark Constants

#define BUTTON_X 10.0f
#define BUTTON_Y 10.0f
#define BUTTON_SPACE 12.0f
#define BUTTON_HEIGHT 48.0f

#define BUTTON_WIDTH 48.0f

@implementation NoteToolbar



@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat viewWidth = self.bounds.size.width;
        
        [self setBackgroundColor:[UIColor redColor]];
        
        CGFloat leftButtonX = BUTTON_X;
        
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        colorButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [colorButton setTitle:@"选择颜色" forState:UIControlStateNormal];
        [colorButton addTarget:self action:@selector(colorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:colorButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *widthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        widthButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [widthButton setTitle:@"选择宽度" forState:UIControlStateNormal];
        [widthButton addTarget:self action:@selector(widthButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:widthButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);

        
        UIButton *penButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        penButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [penButton setTitle:@"钢笔" forState:UIControlStateNormal];
        [penButton addTarget:self action:@selector(penButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:penButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *brushButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        brushButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [brushButton setTitle:@"荧光笔" forState:UIControlStateNormal];
        [brushButton addTarget:self action:@selector(brushButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:brushButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *eraserButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        eraserButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [eraserButton setTitle:@"橡皮擦" forState:UIControlStateNormal];
        [eraserButton addTarget:self action:@selector(eraseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:eraserButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *takeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        takeButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [takeButton setTitle:@"拍照" forState:UIControlStateNormal];
        
        [self addSubview:takeButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        recordButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [recordButton setTitle:@"录音" forState:UIControlStateNormal];
        
        [self addSubview:recordButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        undoButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [undoButton setTitle:@"undo" forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(undoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:undoButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        redoButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [redoButton setTitle:@"redo" forState:UIControlStateNormal];
        [redoButton addTarget:self action:@selector(redoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:redoButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        [clearButton setTitle:@"clear" forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        leftButtonX += (BUTTON_WIDTH + BUTTON_SPACE);
        
        
    }
    return self;
}

- (void)hideNoteToolbar{
    if (self.hidden == NO)
	{
        NSLog(@"hide");
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
	}

}

- (void)showNoteToolbar{
    if (self.hidden == YES)
	{
        NSLog(@"show");
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
	}
}

#pragma mark UIButton action methods

- (void)colorButtonTapped:(UIButton *)button{
    [delegate tappedInNoteToolbar:self choiceColor:button];
}

- (void)widthButtonTapped:(UIButton *)button{
    [delegate tappedInNoteToolbar:self choiceWidth:button];
}

- (void) penButtonTapped:(UIButton *)button{
    [delegate tappedInNoteToolbar:self choicePen:button];
}

- (void) brushButtonTapped:(UIButton *)button{
    [delegate tappedInNoteToolbar:self choiceBrush:button];

}

- (void) eraseButtonTapped:(UIButton *)button{
    [delegate tappedInNoteToolbar:self choiceErase:button];
}

- (void) takeButtonTapped:(UIButton *)button{
    
}

- (void) recordButtonTapped:(UIButton *)button{
    
}
- (void) undoButtonTapped: (UIButton *) button{
    [delegate tappedInNoteToolbar:self undoAction:button];
}
- (void) redoButtonTapped: (UIButton *) button{
    [delegate tappedInNoteToolbar:self redoAction:button];
}
- (void) clearButtonTapped: (UIButton *)button{
    [delegate tappedInNoteToolbar:self clearAction:button];
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
