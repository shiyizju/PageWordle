//
//  ViewController.m
//  Wordle
//
//  Created by quan xiaosha on 4/16/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "RenderingController.h"
#import "TextProcessor.h"

#import "WordsRenderingView.h"

@interface RenderingController ()
{
    
}
@end

@implementation RenderingController


- (void) loadView
{
    self.view = [[[WordsRenderingView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
}

- (void) renderingWithInputText:(NSString *)text
{
    TextProcessor textProcessor([text UTF8String]);
    textProcessor.process();
    std::map<std::string, int> wordmap = textProcessor.getWordMap();
    std::map<std::string, int>::iterator iter;
    for (iter = wordmap.begin(); iter!=wordmap.end(); iter++)
    {
        
    }
}




@end
