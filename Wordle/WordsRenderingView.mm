//
//  StringRenderingView.m
//  Wordle
//
//  Created by quan xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "WordsRenderingView.h"

@interface WordsRenderingView ()
{
    NSMutableArray *words;
    NSMutableArray *fonts;
    NSMutableArray *rects;
}

- (void) doubleTapped:(id) sender;

@end


@implementation WordsRenderingView

@synthesize words;
@synthesize fonts;
@synthesize rects;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(doubleTapped:)];
        [tapGuesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:tapGuesture];
        [tapGuesture release];
    }
    return self;
}

- (void) dealloc
{
    self.words = nil;
    self.fonts = nil;
    self.rects = nil;
    
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    for (int i=0;i<[words count];i++)
        [[words objectAtIndex:i] drawInRect:[(NSValue*)[rects objectAtIndex:i] CGRectValue] withFont:[fonts objectAtIndex:i]];
}

- (void) doubleTapped:(id)sender
{
    [self removeFromSuperview];
}

@end
