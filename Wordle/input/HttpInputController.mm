//
//  HttpInputController.m
//  Wordle
//
//  Created by Xiaosha Quan on 4/26/14.
//  Copyright (c) 2014 Quan Xiaosha. All rights reserved.
//

#import "HttpInputController.h"
#import "UrlConnectionManager.h"
#import "TFHpple.h"
#import "RenderingController.h"


#define URI_BOX_WIDTH_RATIO 0.8
#define URI_BOX_TOP_RATIO   0.3
#define URI_BOX_HEIGHT  44

#define URI_BUTTON_GAP  50

#define BUTTON_WIDTH    100
#define BUTTON_HEIGHT   44


@interface HttpInputController () <UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    UITextField* urlField;
    UIButton* viewButton;
    
    NSMutableData* responseData;
    NSURLConnection* urlConnection;
}

@property (nonatomic, retain) UITextField* urlField;
@property (nonatomic, retain) UIButton* viewButton;
@property (nonatomic, retain) NSMutableData* responseData;
@property (nonatomic, retain) NSURLConnection* urlConnection;
@property (nonatomic, retain) UIActivityIndicatorView* indicatorView;

@end

@implementation HttpInputController

@synthesize urlField;
@synthesize viewButton;
@synthesize responseData;
@synthesize urlConnection;
@synthesize indicatorView;

- (void) setUrlConnection:(NSURLConnection *)_urlConnection
{
    if (urlConnection != _urlConnection)
    {
        [_urlConnection cancel];
        urlConnection = [_urlConnection retain];
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void) dealloc
{
    self.urlField = nil;
    self.viewButton = nil;
    self.responseData = nil;
    self.urlConnection = nil;
    
    [super dealloc];
}

- (void) loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    
    self.urlField = [[[UITextField alloc] initWithFrame:[self frameOfUriBox]] autorelease];
    self.urlField.borderStyle = UITextBorderStyleRoundedRect;
    self.urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.urlField.delegate = self;
    [self.view addSubview:urlField];
    
    self.viewButton = [[[UIButton alloc] init] autorelease];
    [[viewButton layer] setCornerRadius:0.5f];
    [[viewButton layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[viewButton layer] setBorderWidth:1.0f];
    [viewButton setTitle:@"View" forState:UIControlStateNormal];
    [viewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.viewButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewButton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self layoutView];
}
/*
- (void) viewDidAppear:(BOOL)animated
{
    // for test
    [self getHttpUrlContent:@"http://en.wikipedia.org/wiki/time_machine"];
}
*/
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutView];
}

#pragma mark - private method

- (void) buttonTapped:(id)sender
{
    [self getHttpUrlContent:self.urlField.text];
}

- (void) layoutView
{
    [self.urlField setFrame:[self frameOfUriBox]];
    [self.viewButton setFrame:[self frameOfButton]];
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
                                                                    delegate:self
                                                            startImmediately:NO];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setFrame:self.view.bounds];
    [self.view addSubview:indicatorView];
    [indicatorView startAnimating];
    
    [[UrlConnectionManager getInstance] startUrlConnection:lpConnection];
}

- (void) handleData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:self.responseData];
        
        NSArray* arr = [htmlParser searchWithXPathQuery:@"//p//text()"];    //@"//text()[not(ancestor::script)][not(ancestor::style)]"
        
        NSMutableString* htmlText = [NSMutableString string];
        
        for (TFHppleElement* element in arr)
            if (element.content)
                [htmlText appendString:element.content];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.indicatorView stopAnimating];
            self.indicatorView = nil;
            [indicatorView removeFromSuperview];
            
            RenderingController* lpRenderingController = [[[RenderingController alloc] init] autorelease];
            [self.navigationController pushViewController:lpRenderingController animated:YES];
            [lpRenderingController setText:htmlText];
        });
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)ipTextField
{
    [self.urlField resignFirstResponder];
    [self getHttpUrlContent:self.urlField.text];
    return YES;
}

#pragma mark - NSURLConnectionDelegate, NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"http request failed");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    if ([httpResponse statusCode] == 200) {
        self.responseData = [NSMutableData dataWithCapacity:0];
    } else {
        self.responseData = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self handleData];
}

@end
