//
//  ViewController.m
//  Wordle
//
//  Created by quan xiaosha on 4/16/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "RenderingController.h"
#import "AnimatedContentsDisplayLayer.h"
#import "RenderingModel.h"
#import "FBKVOController.h"

#import <AsyncDisplayKit.h>

@interface RenderingController ()
@property (nonatomic, strong) ASDisplayNode* textNodeContainer;
@property (nonatomic, strong) RenderingModel* renderingModel;
@end



@implementation RenderingController

@synthesize text;

@synthesize renderingModel = _renderingModel;
- (RenderingModel*) renderingModel
{
    if (!_renderingModel) {
        _renderingModel = [[RenderingModel alloc] init];
    }
    return _renderingModel;
}

- (void) setTextNodeContainer:(ASDisplayNode *)textNodeContainer
{
    if (_textNodeContainer != textNodeContainer) {
        [_textNodeContainer.layer removeFromSuperlayer];
        _textNodeContainer = textNodeContainer;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textNodeContainer = [[ASDisplayNode alloc] init];
    self.textNodeContainer.layerBacked = true;
    [self.view.layer addSublayer:self.textNodeContainer.layer];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    [self.view addGestureRecognizer:tapGesture];
    
    __weak RenderingController* weakSelf = self;
    [self.KVOController observe:self.renderingModel keyPath:@"isRendering" options:NULL block:^(id observer, id object, NSDictionary *change) {
        RenderingController* strongSelf = weakSelf;
        strongSelf.textNodeContainer = [[ASDisplayNode alloc] init];
        strongSelf.textNodeContainer.layerBacked = true;
        [strongSelf.view.layer addSublayer:strongSelf.textNodeContainer.layer];
    }];
}

- (void) dealloc
{
    [self.KVOController unobserveAll];
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self rendering];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self rendering];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_renderingModel cancelRendering];
}

- (void) hideNavigationBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) singleTap {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (void) rendering
{
    self.renderingModel.size = self.view.frame.size;
    self.renderingModel.scale = [[UIScreen mainScreen] scale];
    self.renderingModel.rawText = self.text;
    
    [self.renderingModel renderingWithDispalyBlock:^(UIImage* image, float imageScale, CGRect rect){
        // Display string in main queue
        ASDisplayNode* asNode = self.textNodeContainer;
        dispatch_async(dispatch_get_main_queue(), ^{
            ASImageNode* imageNode = [[ASImageNode alloc] init];
            imageNode.layerBacked = true;
            imageNode.image = image;
            imageNode.frame = rect;
            [asNode addSubnode:imageNode];
        });
    }];
}

@end
