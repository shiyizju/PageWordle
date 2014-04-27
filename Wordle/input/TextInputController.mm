//
//  TextInputController.m
//  Wordle
//
//  Created by Quan, Xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "TextInputController.h"
#import "TextInputView.h"

#import "RenderingController.h"

@interface TextInputController () <TextInputViewDelegate>

@end


@implementation TextInputController


- (void) loadView
{
    self.view = [[[TextInputView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    
    [(TextInputView*)[self view] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.view setNeedsLayout];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma UITextViewDelegate

- (void) endInputWithString:(NSString *)string
{
    RenderingController* lpRenderingController = [[[RenderingController alloc] init] autorelease];
    [self.navigationController pushViewController:lpRenderingController animated:YES];
    [lpRenderingController setText:string];
}

@end