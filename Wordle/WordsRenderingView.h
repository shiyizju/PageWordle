//
//  StringRenderingView.h
//  Wordle
//
//  Created by quan xiaosha on 4/17/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WordsRenderingViewDelegate

- (void) singleTap;
- (void) doubleTap;

@end

@interface WordsRenderingView : UIView

@property (nonatomic, assign) id<WordsRenderingViewDelegate> delegate;

@property (nonatomic, retain) NSArray* words;
@property (nonatomic, retain) NSArray* fonts;
@property (nonatomic, retain) NSArray* rects;

@end
