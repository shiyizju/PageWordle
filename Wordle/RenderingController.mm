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
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.textNodeContainer.layer removeFromSuperlayer];
    self.textNodeContainer = [[ASDisplayNode alloc] init];
    self.textNodeContainer.layerBacked = true;
    [self.view.layer addSublayer:self.textNodeContainer.layer];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self rendering];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self rendering];
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
    
    [self.renderingModel renderingWithDispalyBlock:^(CGImageRef image, float imageScale, CGRect rect){
        // Display string in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            ASImageNode* imageNode = [[ASImageNode alloc] init];
            imageNode.layerBacked = true;
            imageNode.image = [UIImage imageWithCGImage:image scale:imageScale orientation:UIImageOrientationUp];
            imageNode.frame = rect;
            [self.textNodeContainer addSubnode:imageNode];
            /*
            ASTextNode* textNode = [[ASTextNode alloc] init];//WithLayerClass:[_ASDisplayLayer class]];
            textNode.layerBacked = true;
            textNode.frame = rect;
            textNode.attributedString = [[NSAttributedString alloc] initWithString:word attributes:@{NSFontAttributeName:font}];
            [self.textNodeContainer addSubnode:textNode];*/
        });
    }];
}

@end
