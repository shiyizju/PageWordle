//
//  TextInputView.h
//  Wordle
//
//  Created by Quan, Xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextInputViewDelegate

- (void) endInputWithString:(NSString*)string;

@end

@interface TextInputView : UIView

@property (nonatomic, assign) id<TextInputViewDelegate> delegate;

@end
