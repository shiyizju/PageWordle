//
//  InputTextController.h
//  Wordle
//
//  Created by Quan, Xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputTextController;

@protocol InputTextControllerDelegate

- (void) inputTextController:(InputTextController*)inputTextController endInputWithString:(NSString*)inputString;

@end


@interface InputTextController : UIViewController

@property (nonatomic, assign) id<InputTextControllerDelegate> delegate;

@end
