//
//  ViewController.m
//  Wordle
//
//  Created by quan xiaosha on 4/16/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "RenderingController.h"

#import "StringRenderingView.h"

@interface RenderingController ()

@end

@implementation RenderingController

- (void) loadView
{
    self.view = [[[StringRenderingView alloc] initWithFrame:
                  CGRectMake(0,
                             0,
                             [UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height)] autorelease];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
