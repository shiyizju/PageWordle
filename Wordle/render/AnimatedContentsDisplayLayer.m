//
//  AnimatedContentsDisplayLayer.m
//  Wordle
//
//  Created by Xiaosha Quan on 12/17/14.
//  Copyright (c) 2014 Quan Xiaosha. All rights reserved.
//

#import "AnimatedContentsDisplayLayer.h"

@implementation AnimatedContentsDisplayLayer

- (id<CAAction>)actionForKey:(NSString *)event
{
    if ([event isEqualToString:@"contents"]) {
        CATransition* transition = [[CATransition alloc] init];
        transition.duration = 1.0;
        transition.type = kCATransitionFade;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        return transition;
    }
    
    return nil;
}

@end
