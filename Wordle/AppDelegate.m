//
//  AppDelegate.m
//  Wordle
//
//  Created by quan xiaosha on 4/16/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "AppDelegate.h"

#import "RenderingController.h"
#import "InputTextController.h"

@interface AppDelegate () <InputTextControllerDelegate>
{
    RenderingController *renderingController;
    InputTextController *inputTextController;
}

@end


@implementation AppDelegate

@synthesize renderingController, inputTextController;

- (void)dealloc
{
    [_window release];
    
    [self setRenderingController:nil];
    [self setInputTextController:nil];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
//  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
   
/*
    char pixels[25] = { 0, 1, 0, 0, 0,
                        0, 0, 0, 0, 0,
                        1, 0, 1, 1, 0,
                        0, 0, 1, 0, 0,
                        0, 0, 0, 0, 0 };
    
    Bitmap bitmap(5, 5, pixels);
*/
    
    
//    self.inputTextController = [[[InputTextController alloc] init] autorelease];
//    [inputTextController setDelegate:self];
//    [self.window addSubview:inputTextController.view];
    
    NSString* inputString = @"On 26 November 1945 his nomination as Chief of Naval Operations was confirmed by the US Senate, and on 15 December 1945 he relieved Fleet Admiral Ernest J. King. He had assured the President that he was willing to serve as the CNO for one two-year term, but no longer. He tackled the difficult task of reducing the most powerful navy in the world to a fraction of its war-time strength, while establishing and overseeing active and reserve fleets with the strength and readiness required to support national policy. The The The The The The The The The The The";
    
    self.renderingController = [[[RenderingController alloc] init] autorelease];
    [renderingController renderingWithInputText:inputString];
    [self.window addSubview:renderingController.view];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - InputTextControllerDelegate

- (void) inputTextController:(InputTextController *)inputTextController endInputWithString:(NSString *)inputString
{
    self.renderingController = [[[RenderingController alloc] init] autorelease];
    [renderingController renderingWithInputText:inputString];
    [self.window addSubview:renderingController.view];
}

@end
