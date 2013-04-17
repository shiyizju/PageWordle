//
//  InputTextView.m
//  Wordle
//
//  Created by Quan, Xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "InputTextView.h"


#define TEXT_VIEW_MARGIN 20

#define BUTTON_HEIGHT   40
#define BUTTON_WIDTH    100

@interface InputTextView () <UITextViewDelegate>
{
    id<InputTextViewDelegate> delegate;
    UITextView *textView;
    UIButton *doneButton;
}

- (CGRect) textViewFrame;
- (CGRect) buttonFrame;

- (void) segmentValueChange:(id) sender;
- (void) doneButtonClicked:(id) sender;

@end


@implementation InputTextView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        textView = [[UITextView alloc] initWithFrame:[self textViewFrame]];
        [[textView layer] setCornerRadius:5.0f];
        [[textView layer] setBorderColor:[[UIColor grayColor] CGColor]];
        [[textView layer] setBorderWidth:1.0f];
        
        
        UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Clear", @"Done", nil]];
        [segment setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segment setMomentary:YES];
        [segment addTarget:self action:@selector(segmentValueChange:) forControlEvents:UIControlEventValueChanged];
        [textView setInputAccessoryView:segment];
        [segment setFrame:CGRectMake(0, 0, 80, 40)];
        [segment release];
        
        doneButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [doneButton setFrame:[self buttonFrame]];
        [doneButton setTitle:@"OK" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:textView];
        [self addSubview:doneButton];
        [self setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    }
    
    return self;
}

- (void) dealloc
{
    [textView release];
    [doneButton release];
    
    [super dealloc];
}

- (CGRect) textViewFrame
{
    return CGRectMake(TEXT_VIEW_MARGIN,
                      TEXT_VIEW_MARGIN,
                      self.frame.size.width - 2*TEXT_VIEW_MARGIN,
                      self.frame.size.height - 3*TEXT_VIEW_MARGIN - BUTTON_HEIGHT);
}

- (CGRect) buttonFrame
{
    return CGRectMake((self.frame.size.width-BUTTON_WIDTH)/2.0f,
                      self.frame.size.height - TEXT_VIEW_MARGIN - BUTTON_HEIGHT,
                      BUTTON_WIDTH,
                      BUTTON_HEIGHT);
}

- (void) segmentValueChange:(id)sender
{
    int index = [(UISegmentedControl*)sender selectedSegmentIndex];
    if (index==0)
        [textView setText:@""];
    else
        [textView resignFirstResponder];
}

- (void) doneButtonClicked:(id)sender
{
    [delegate endInputWithString:[textView text]];
}

@end
