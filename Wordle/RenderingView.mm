//
//  StringRenderingView.m
//  Wordle
//
//  Created by quan xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "RenderingView.h"

@interface RenderingView ()
{
    NSMutableArray *words;
    NSMutableArray *fonts;
    NSMutableArray *rects;
}

@end


@implementation RenderingView

@synthesize words;
@synthesize fonts;
@synthesize rects;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tapGuesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        [tapGuesture1 setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tapGuesture1];
        [tapGuesture1 release];
        
        UITapGestureRecognizer *tapGuesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        [tapGuesture2 setNumberOfTapsRequired:2];
        [self addGestureRecognizer:tapGuesture2];
        [tapGuesture2 release];
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

- (void) singleTap
{
    [self.delegate singleTap];
}

- (void) doubleTap
{
    [self.delegate doubleTap];
}

@end
