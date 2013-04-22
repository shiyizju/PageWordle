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
{
    NSMutableArray* words;
    NSMutableArray* count;
}

@property (nonatomic, retain) NSMutableArray* words;
@property (nonatomic, retain) NSMutableArray* count;

@end



@implementation RenderingController

@synthesize words;
@synthesize count;


- (void) dealloc
{
    self.words = nil;
    self.count = nil;
    
    [super dealloc];
}

- (void) loadView
{
    self.view = [[[WordsRenderingView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
}

- (void) renderingWithInputText:(NSString *)text
{
    self.words = [NSMutableArray array];
    self.count = [NSMutableArray array];
    
    TextProcessor textProcessor([text UTF8String]);
    textProcessor.process();
    std::map<std::string, int> wordmap = textProcessor.getWordMap();
    std::map<std::string, int>::iterator iter;
    for (iter = wordmap.begin(); iter!=wordmap.end(); iter++)
    {
        [self.words addObject:[NSString stringWithUTF8String:iter->first.c_str()]];
        [self.count addObject:[NSNumber numberWithInt:iter->second]];
    }
    
    
    
}





@end
