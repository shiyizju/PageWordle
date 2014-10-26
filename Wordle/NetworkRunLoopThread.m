//
//  NetworkManager.m
//  Wordle
//
//  Created by Xiaosha Quan on 4/28/14.
//  Copyright (c) 2014 Quan Xiaosha. All rights reserved.
//

#import "NetworkRunLoopThread.h"

@interface NetworkRunLoopThread ()
@property (nonatomic, readonly) NSRunLoop* runLoop;
@end

@implementation NetworkRunLoopThread {
    dispatch_group_t _waitGroup;
}

+ (NSRunLoop*) networkRunLoop
{
    static NetworkRunLoopThread* workThread = nil;
    static NSRunLoop* networkRunLoop = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        workThread = [[NetworkRunLoopThread alloc] init];
        workThread.name = @"com.laopobing.PageWordle.NetworkThread";
        [workThread start];
        
        networkRunLoop = [workThread runLoop];
    });
    
    return networkRunLoop;
}

@synthesize runLoop = _runLoop;
- (NSRunLoop*) runLoop
{
    // use dispatch group to make sure the thread is started.
    dispatch_group_wait(_waitGroup, DISPATCH_TIME_FOREVER);
    
    return _runLoop;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _waitGroup = dispatch_group_create();
        
        // enter the group manually.
        dispatch_group_enter(_waitGroup);
    }
    return self;
}

- (void) main
{
    @autoreleasepool {
        
        _runLoop = [NSRunLoop currentRunLoop];
        
        // leave group manually.
        dispatch_group_leave(_waitGroup);
        
        // runMode:beforeDate: will exit immdediately if no input source is attached to it.
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture] interval:0.0 target:nil selector:nil userInfo:nil repeats:NO];
        [_runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        
        while ([_runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
        
        assert(NO);
    }
}

@end
