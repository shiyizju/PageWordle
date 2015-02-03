//
//  RenderingTask.h
//  Wordle
//
//  Created by Xiaosha Quan on 2/1/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RenderingTask : NSObject

@property (nonatomic, assign) bool isCancelled;

- (instancetype) initWithRawText:(NSString*)rawText size:(CGSize)size scale:(CGFloat)scale;

- (void) startRenderingWithEnumerationBlock:(void (^)(UIImage* image, float scale, CGRect rect)) enumBlock
                                   onFinish:(void (^)(bool isCancelled)) finishBlock;

- (void) cancel;

@end
