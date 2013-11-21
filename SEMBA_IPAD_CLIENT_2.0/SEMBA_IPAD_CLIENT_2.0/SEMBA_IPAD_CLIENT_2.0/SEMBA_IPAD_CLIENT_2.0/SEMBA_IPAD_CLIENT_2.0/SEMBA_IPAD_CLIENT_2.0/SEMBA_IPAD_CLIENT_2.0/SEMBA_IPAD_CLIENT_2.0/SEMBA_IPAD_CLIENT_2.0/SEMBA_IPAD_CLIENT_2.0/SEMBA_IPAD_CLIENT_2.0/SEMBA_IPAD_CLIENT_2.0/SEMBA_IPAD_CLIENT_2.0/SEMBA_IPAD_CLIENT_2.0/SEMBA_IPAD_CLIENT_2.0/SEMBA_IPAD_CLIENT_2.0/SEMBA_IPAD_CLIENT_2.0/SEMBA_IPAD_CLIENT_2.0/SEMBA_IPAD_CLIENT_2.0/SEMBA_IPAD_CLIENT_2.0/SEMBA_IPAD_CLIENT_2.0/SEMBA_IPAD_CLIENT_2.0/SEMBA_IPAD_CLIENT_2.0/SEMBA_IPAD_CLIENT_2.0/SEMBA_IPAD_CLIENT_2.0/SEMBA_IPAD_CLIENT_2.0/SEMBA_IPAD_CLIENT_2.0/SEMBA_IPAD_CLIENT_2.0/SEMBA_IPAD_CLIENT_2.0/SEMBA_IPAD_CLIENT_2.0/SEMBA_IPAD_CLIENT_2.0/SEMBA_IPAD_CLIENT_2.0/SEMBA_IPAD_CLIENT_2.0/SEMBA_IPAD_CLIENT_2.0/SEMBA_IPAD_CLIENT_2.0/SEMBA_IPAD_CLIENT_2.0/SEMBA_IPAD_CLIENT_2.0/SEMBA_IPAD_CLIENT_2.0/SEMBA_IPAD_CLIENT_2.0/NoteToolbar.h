//
//  NoteToolbar.h
//  Reader
//
//  Created by yaodd on 13-10-20.
//
//

#import <UIKit/UIKit.h>
@class NoteToolbar;
@protocol NoteToolbarDelegate <NSObject>

@required

- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceColor:(UIButton *)button;
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceWidth:(UIButton *)button;
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choicePen:(UIButton *)button;
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceBrush:(UIButton *)button;
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar choiceErase:(UIButton *)button;
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar undoAction:(UIButton *)button;
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar redoAction:(UIButton *)button;
- (void)tappedInNoteToolbar:(NoteToolbar *)toolbar clearAction:(UIButton *)button;
@end

@interface NoteToolbar : UIView

@property (nonatomic, weak, readwrite) id <NoteToolbarDelegate> delegate;



- (void)hideNoteToolbar;
- (void)showNoteToolbar;

@end
