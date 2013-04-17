//
//  InputTextView.h
//  Wordle
//
//  Created by Quan, Xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputTextViewDelegate

- (void) endInputWithString:(NSString*)string;

@end

@interface InputTextView : UIView

@property (nonatomic, assign) id<InputTextViewDelegate> delegate;

@end
