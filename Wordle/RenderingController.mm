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
    
    std::vector<std::pair<std::string, int> >* wordVector = textProcessor.getWordsVectorSortedByCount();
    std::vector<std::pair<std::string, int> >::iterator iter;
    
    for (iter = wordVector->begin(); iter!=wordVector->end(); iter++)
    {
        NSString* word = [NSString stringWithUTF8String: iter->first.c_str()];
        UIFont*   font = [UIFont systemFontOfSize: iter->second * 10];
        
        CGSize wordSize = [word sizeWithFont:font];
        
        float x = rand() % (int)(self.view.bounds.size.width  - wordSize.width);
        float y = rand() % (int)(self.view.bounds.size.height - wordSize.height);

        CGRect rect = CGRectMake(x, y, wordSize.width, wordSize.height);
        
        [words addObject:word];
        [fonts addObject:font];
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }
    
    [(WordsRenderingView*)self.view setWords:words];
    [(WordsRenderingView*)self.view setFonts:fonts];
    [(WordsRenderingView*)self.view setRects:rects];
}

@end
