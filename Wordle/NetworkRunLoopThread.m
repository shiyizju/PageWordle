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
    // Use dispatch group to make sure the thread is started.
    dispatch_wait(_waitGroup, DISPATCH_TIME_FOREVER);
    
    return _runLoop;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _waitGroup = dispatch_group_create();
        
        // enter the group.
        dispatch_group_enter(_waitGroup);
    }
    return self;
}

- (void) main
{
    @autoreleasepool {
        
        _runLoop = [NSRunLoop currentRunLoop];
        dispatch_group_leave(_waitGroup);
        
        while (true) {
            [_runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        assert(NO);
    }
}

- (void) dealloc
{
    dispatch_release(_waitGroup);
    
    [super dealloc];
}

@end
