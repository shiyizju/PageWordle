//
//  ViewController.m
//  Wordle
//
//  Created by quan xiaosha on 4/16/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "RenderingController.h"
#import "TextProcessor.h"

#import "Bitmap.h"

#import "WordsRenderingView.h"


@interface RenderingController ()

- (CGPoint) getRandomPosition;

@end



@implementation RenderingController

/*
- (id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}*/

- (void) dealloc
{
    [super dealloc];
}

- (void) loadView
{
    self.view = [[[WordsRenderingView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
}

- (void) renderingWithInputText:(NSString *)text
{
    NSMutableArray* words = [NSMutableArray array];
    NSMutableArray* fonts = [NSMutableArray array];
    NSMutableArray* rects = [NSMutableArray array];
    
    Bitmap bitmap(self.view.bounds.size.width, self.view.bounds.size.height);

    TextProcessor textProcessor([text UTF8String]);
    textProcessor.process();
    std::map<std::string, int> wordmap = textProcessor.getWordMap();
    std::map<std::string, int>::iterator iter;
    for (iter = wordmap.begin(); iter!=wordmap.end(); iter++)
    {
        NSString* word = [NSString stringWithUTF8String: iter->first.c_str()];
        UIFont*   font = [UIFont systemFontOfSize: iter->second * 10];
        
        CGSize size = [word sizeWithFont:font];
        CGPoint origin = [self getRandomPosition];
        
        CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
        
        [words addObject:word];
        [fonts addObject:font];
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }
    
    [(WordsRenderingView*)self.view setWords:words];
    [(WordsRenderingView*)self.view setFonts:fonts];
    [(WordsRenderingView*)self.view setRects:rects];
}

- (CGPoint) getRandomPosition
{
    int x = rand() % (int)self.view.bounds.size.width;
    int y = rand() % (int)self.view.bounds.size.height;
    
    return CGPointMake(x, y);
}


@end
