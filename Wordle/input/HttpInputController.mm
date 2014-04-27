//
//  HttpInputController.m
//  Wordle
//
//  Created by Xiaosha Quan on 4/26/14.
//  Copyright (c) 2014 Quan Xiaosha. All rights reserved.
//

#import "HttpInputController.h"
#import "TFHpple.h"

#define URI_BOX_WIDTH_RATIO 0.8
#define URI_BOX_TOP_RATIO   0.3
#define URI_BOX_HEIGHT  44

#define URI_BUTTON_GAP  50

#define BUTTON_WIDTH    100
#define BUTTON_HEIGHT   44

@interface HttpInputController () <UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    UITextField* urlField;
    UIButton* goButton;
    
    NSMutableData* responseData;
}

@property (nonatomic, retain) UITextField* urlField;
@property (nonatomic, retain) UIButton* goButton;
@property (nonatomic, retain) NSMutableData* responseData;

@end

@implementation HttpInputController

@synthesize urlField;
@synthesize goButton;
@synthesize responseData;

- (void) dealloc
{
    self.urlField = nil;
    self.goButton = nil;
    self.responseData = nil;
    
    [super dealloc];
}

- (void) loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    
    self.urlField = [[[UITextField alloc] initWithFrame:[self frameOfUriBox]] autorelease];
    [self.urlField setBorderStyle:UITextBorderStyleRoundedRect];
    self.urlField.delegate = self;
    [self.view addSubview:urlField];
    
    self.goButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.goButton setBackgroundColor:[UIColor whiteColor]];
    [self.goButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goButton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self layoutView];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutView];
}

- (void) buttonTapped:(id)sender
{
    [self getHttpUrlContent:self.urlField.text];
}

- (void) layoutView
{
    [self.urlField setFrame:[self frameOfUriBox]];
    [self.goButton setFrame:[self frameOfButton]];
}

- (CGRect) frameOfUriBox
{
    return CGRectMake(self.view.frame.size.width  * (1 - URI_BOX_WIDTH_RATIO) / 2.0f,
                      self.view.frame.size.height * URI_BOX_TOP_RATIO,
                      self.view.frame.size.width  * URI_BOX_WIDTH_RATIO,
                      URI_BOX_HEIGHT);
}

- (CGRect) frameOfButton
{
    return CGRectMake((self.view.frame.size.width - BUTTON_WIDTH) / 2.0f,
                      self.view.frame.size.height * URI_BOX_TOP_RATIO + + URI_BOX_HEIGHT + URI_BUTTON_GAP,
                      BUTTON_WIDTH,
                      BUTTON_HEIGHT);
}

- (void) getHttpUrlContent:(NSString*)urlStr
{
    NSURLConnection* lpConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]
                                                                    delegate:self];
    [lpConnection start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"http request failed");
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    if ([httpResponse statusCode] == 200)
    {
        self.responseData = [NSMutableData dataWithCapacity:0];
        NSLog(@"http request OK");
    }
    else
    {
        self.responseData = nil;
        NSLog(@"http request error");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:self.responseData];
    
    NSString* queryString = @"//div[@class='content-wrapper']/ul/li/a";
    
    NSArray* arr = [htmlParser searchWithXPathQuery:queryString];
    
    NSLog(@"http request finish");
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)ipTextField
{
    [self getHttpUrlContent:self.urlField.text];
    return YES;
}

@end
