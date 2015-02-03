//
//  Model.m
//  Wordle
//
//  Created by Xiaosha Quan on 1/24/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import "RenderingModel.h"
#import "RenderingTask.h"
#import "UIImage+Wordle.h"
#import "Word.h"

@interface RenderingModel ()
@property (nonatomic, retain) RenderingTask* renderingTask;
@end


@implementation RenderingModel

+ (void) initialize {
    // set random seed.
    srand((unsigned int)time(0));
}

- (void) setRenderingTask:(RenderingTask *)renderingTask
{
    if (_renderingTask != renderingTask) {
        // Cancel previous task.
        [_renderingTask cancel];
        _renderingTask = renderingTask;
    }
}

- (RenderingTask*) newRenderingTask {
    
    RenderingTask* lpRenderingTask = [[RenderingTask alloc] initWithRawText:self.rawText size:self.size scale:self.scale];
    return lpRenderingTask;
}

- (void) cancelRendering {
    self.renderingTask = nil;
}

- (void) renderingWithDispalyBlock:(SingleWordDisplayBlock)displayBlock
{
    self.renderingTask = [self  newRenderingTask];
    
    // Triger kvo to notify controller to clear view.
    [self willChangeValueForKey:@"isRendering"];
    [self  didChangeValueForKey:@"isRendering"];
    
    NSDate* startDate = [NSDate date];
    [_renderingTask startRenderingWithEnumerationBlock:^(UIImage* image, float scale, CGRect rect) {
        displayBlock(image, scale, rect);
    } onFinish:^(bool isCancelled) {
        if (isCancelled) {
            NSLog(@"Rendering task cancelled");
        }
        else {
            NSLog(@"Rendering task finished. Total Time: %f", [[NSDate date] timeIntervalSinceDate:startDate]);
            
        }
    }];
}

@end
