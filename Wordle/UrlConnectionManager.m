//
//  NetworkManager.m
//  Wordle
//
//  Created by Xiaosha Quan on 4/28/14.
//  Copyright (c) 2014 Quan Xiaosha. All rights reserved.
//

#import "UrlConnectionManager.h"

static UrlConnectionManager* pInstance = nil;

@interface UrlConnectionManager()
{
    NSThread* workThread;
}
@end


@implementation UrlConnectionManager

+ (UrlConnectionManager*) getInstance
{
    if (pInstance == nil) {
        @synchronized([UrlConnectionManager class]) {
            if (pInstance == nil) {
                pInstance = [[UrlConnectionManager alloc] init];
            }
        }
    }
    return pInstance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        workThread = [[NSThread alloc] initWithTarget:self selector:@selector(startWorkThread) object:nil];
        [workThread start];
    }
    return self;
}

- (void) dealloc
{
    [workThread cancel];
    [workThread release];
    
    [super dealloc];
}

- (void) startUrlConnection:(NSURLConnection*)connection
{
    [self performSelector:@selector(startConnectionInternal:) onThread:workThread withObject:connection waitUntilDone:NO];
}

#pragma mark - private method

- (void) startWorkThread
{    
    while (true)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void) startConnectionInternal:(NSURLConnection*)connection
{
    // This function should run on work thread
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    NSLog(@"%@ started", [connection description]);
}



@end
