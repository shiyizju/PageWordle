//
//  InputTextController.m
//  Wordle
//
//  Created by Quan, Xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "InputTextController.h"
#import "InputTextView.h"

@interface InputTextController () <InputTextViewDelegate>
{
    id <InputTextControllerDelegate> delegate;
}

@end

@implementation InputTextController

@synthesize delegate;

- (void) loadView
{
    self.view = [[[InputTextView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    [(InputTextView*)[self view] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITextViewDelegate

- (void) endInputWithString:(NSString *)string
{
    [delegate inputTextController:self endInputWithString:string];
}

@end