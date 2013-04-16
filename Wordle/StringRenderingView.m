//
//  StringRenderingView.m
//  Wordle
//
//  Created by quan xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "StringRenderingView.h"

@interface StringRenderingView ()
{
    NSArray* strings;
    NSArray* fonts;
    NSArray* colors;
}

@end


@implementation StringRenderingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSString* str = @"Hello World";
    [str drawAtPoint:self.center withFont:[UIFont systemFontOfSize:20]];
}

@end
