//
//  HttpInputController.m
//  Wordle
//
//  Created by Xiaosha Quan on 4/26/14.
//  Copyright (c) 2014 Quan Xiaosha. All rights reserved.
//

#import "HttpInputController.h"
#import "NetworkRunLoopThread.h"
#import "TFHpple.h"
#import "RenderingController.h"


static const CGFloat URI_BOX_WIDTH_RATIO = 0.8;
static const CGFloat URI_BOX_TOP_RATIO   = 0.3;
static const CGFloat URI_BOX_HEIGHT      =  44;
static const CGFloat URI_BUTTON_GAP      =  50;
static const CGFloat BUTTON_WIDTH        = 120;
static const CGFloat BUTTON_HEIGHT       =  44;


@interface HttpInputController () <UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) UITextField* urlField;
@property (nonatomic, strong) UIButton* viewButton;
@property (nonatomic, strong) NSMutableData* responseData;
@property (nonatomic, strong) NSURLConnection* urlConnection;
@property (nonatomic, strong) UIActivityIndicatorView* indicatorView;

@end

@implementation HttpInputController

@synthesize indicatorView = _indicatorView;
- (void) setIndicatorView:(UIActivityIndicatorView *)indicatorView {
    
    if (_indicatorView != indicatorView) {
        [_indicatorView stopAnimating];
        [_indicatorView removeFromSuperview];
        _indicatorView = indicatorView;
    }
}

@synthesize urlConnection = _urlConnection;
- (void) setUrlConnection:(NSURLConnection *)urlConnection {
    
    if (_urlConnection != urlConnection) {
        [_urlConnection cancel];
        _urlConnection = urlConnection;
    }
}

- (void) viewDidLoad {
    
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0f];
    
    self.urlField = [[UITextField alloc] initWithFrame:[self frameOfUriBox]];
    _urlField.borderStyle = UITextBorderStyleRoundedRect;
    _urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _urlField.delegate = self;
    _urlField.text = @"http://en.wikipedia.org/wiki/Alan_Turing";               // Demo Url.
    //_urlField.text = @"http://baike.baidu.com/subview/22509/6058445.htm";
    [self.view addSubview:_urlField];
    
    self.viewButton = [[UIButton alloc] init];
    [[_viewButton layer] setCornerRadius:5.0f];
    [[_viewButton layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[_viewButton layer] setBorderWidth:1.0f];
    [_viewButton setTitle:@"View" forState:UIControlStateNormal];
    [_viewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_viewButton addTarget:self action:@selector(viewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_viewButton];
}

- (void) viewWillLayoutSubviews {
    
    _urlField.frame   = [self frameOfUriBox];
    _viewButton.frame = [self frameOfViewButton];
    _indicatorView.frame = self.view.bounds;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - private method

- (void) viewButtonTapped:(id)sender
{
    [self getHttpUrlContent:self.urlField.text];
}

- (CGRect) frameOfUriBox
{
    return CGRectMake(self.view.frame.size.width  * (1 - URI_BOX_WIDTH_RATIO) / 2.0f,
                      self.view.frame.size.height * URI_BOX_TOP_RATIO,
                      self.view.frame.size.width  * URI_BOX_WIDTH_RATIO,
                      URI_BOX_HEIGHT);
}

- (CGRect) frameOfViewButton
{
    return CGRectMake((self.view.frame.size.width  - BUTTON_WIDTH) / 2.0f,
                       self.view.frame.size.height * URI_BOX_TOP_RATIO + + URI_BOX_HEIGHT + URI_BUTTON_GAP,
                       BUTTON_WIDTH,
                       BUTTON_HEIGHT );
}

- (void) getHttpUrlContent:(NSString*)urlStr
{
    if (![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"]) {
        urlStr = [@"http://" stringByAppendingString:urlStr];
    }
    
    NSURLConnection* lpConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]
                                                                    delegate:self
                                                            startImmediately:NO];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicatorView setFrame:self.view.bounds];
    [self.view addSubview:_indicatorView];
    [_indicatorView startAnimating];
    
    [lpConnection scheduleInRunLoop:[NetworkRunLoopThread networkRunLoop] forMode:NSDefaultRunLoopMode];
    [lpConnection start];
}

- (void) handleData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:self.responseData];
        
        NSArray* arr = [htmlParser searchWithXPathQuery:@"//p//text() | //div[@class='para']//text()"];    //@"//text()[not(ancestor::script)][not(ancestor::style)]"
        
        NSMutableString* htmlText = [NSMutableString string];
        
        for (TFHppleElement* element in arr) {
            if (element.content) {
                [htmlText appendString:element.content];
                [htmlText appendString:@"\n"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.indicatorView stopAnimating];
            self.indicatorView = nil;
            
            RenderingController* lpRenderingController = [[RenderingController alloc] init];
            [lpRenderingController setText:htmlText];
            [self.navigationController pushViewController:lpRenderingController animated:YES];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorView = nil;
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorView = nil;
    });
    
    [self handleData];
}

@end
