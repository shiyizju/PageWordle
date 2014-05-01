//
//  TextInputView.m
//  Wordle
//
//  Created by Quan, Xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TextInputView.h"


#define TEXT_VIEW_PADDING   20

#define BUTTON_HEIGHT       44
#define BUTTON_WIDTH        100

@interface TextInputView () <UITextViewDelegate>
{
    id<TextInputViewDelegate> delegate;
    UITextView *textView;
    UIButton *doneButton;
}

- (CGRect) textViewFrame;
- (CGRect) buttonFrame;

- (void) segmentValueChange:(id) sender;
- (void) doneButtonClicked:(id) sender;

@end


@implementation TextInputView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        textView = [[UITextView alloc] init];
        [[textView layer] setCornerRadius:5.0f];
        [[textView layer] setBorderColor:[[UIColor grayColor] CGColor]];
        [[textView layer] setBorderWidth:1.0f];
        [textView setFont:[UIFont systemFontOfSize:15.0f]];
        
        UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Clear", @"Done", nil]];
        [segment setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segment setMomentary:YES];
        [segment addTarget:self action:@selector(segmentValueChange:) forControlEvents:UIControlEventValueChanged];
        [textView setInputAccessoryView:segment];
        [segment setFrame:CGRectMake(0, 0, 80, 30)];
        [segment release];
        
        doneButton = [[UIButton alloc] init];
        [[doneButton layer] setCornerRadius:5.0f];
        [[doneButton layer] setBorderColor:[[UIColor grayColor] CGColor]];
        [[doneButton layer] setBorderWidth:1.0f];
        [doneButton setTitle:@"OK" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        
        [self layoutSubviews];
    }
    
    return self;
}

- (void) layoutSubviews
{
    [textView setFrame:[self textViewFrame]];
    [self addSubview:textView];
    
    [doneButton setFrame:[self buttonFrame]];
    [self addSubview:doneButton];
}

- (void) dealloc
{
    [textView release];
    [doneButton release];
    
    [super dealloc];
}

- (CGRect) textViewFrame
{
    float top = 64 + TEXT_VIEW_PADDING;
    
    return CGRectMake(TEXT_VIEW_PADDING,
                      top,
                      self.frame.size.width  - 2*TEXT_VIEW_PADDING,
                      self.frame.size.height - 2*TEXT_VIEW_PADDING - BUTTON_HEIGHT - top);
}

- (CGRect) buttonFrame
{
    return CGRectMake((self.frame.size.width - BUTTON_WIDTH)/2.0f,
                      self.frame.size.height - TEXT_VIEW_PADDING - BUTTON_HEIGHT,
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
