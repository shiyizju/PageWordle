//
//  AppDelegate.h
//  Wordle
//
//  Created by quan xiaosha on 4/16/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RenderingController;
@class InputTextController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RenderingController* renderingController;
@property (strong, nonatomic) InputTextController* inputTextController;

@end
