//
//  StringRenderingView.h
//  Wordle
//
//  Created by quan xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RenderingViewDelegate

- (void) singleTap;
- (void) doubleTap;

@end

@interface RenderingView : UIView

@property (nonatomic, assign) id<RenderingViewDelegate> delegate;

@property (nonatomic, retain) NSArray* words;
@property (nonatomic, retain) NSArray* fonts;
@property (nonatomic, retain) NSArray* rects;

- (void) clear;

@end
