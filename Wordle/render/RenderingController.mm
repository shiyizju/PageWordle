//
//  ViewController.m
//  Wordle
//
//  Created by quan xiaosha on 4/16/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#import "RenderingController.h"
#import "TextProcessor.h"
#import "Bitmap.h"
#import "AnimatedContentsDisplayLayer.h"

#import <AsyncDisplayKit.h>

@interface RenderingController ()
@property (nonatomic, strong) ASDisplayNode* textNodeContainer;
@end



@implementation RenderingController

@synthesize text;

+ (dispatch_queue_t) renderingQueue
{
    static dispatch_queue_t renderingQueue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        renderingQueue = dispatch_queue_create("com.quanxiaosha.Worlde.Rendering", DISPATCH_QUEUE_CONCURRENT);
        // Set target queu with high priority
        dispatch_set_target_queue(renderingQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    });
    
    return renderingQueue;
}

+ (void) initialize {
    // set random seed.
    srand((unsigned int)time(0));
}

- (void) viewDidLoad
{
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
    dispatch_async([RenderingController renderingQueue], ^{
        [self rendering];
    });
}

- (void) viewDidAppear:(BOOL)animated
{
    dispatch_async([RenderingController renderingQueue], ^{
        [self rendering];
    });
}

- (void) hideNavigationBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) singleTap {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

// Find the font size for the word with highest frequency
- (float) fontSizeOfString:(NSString*)string withConstrainedSize:(CGSize)size
{
    int low = 0;
    int up  = 15;
    
    // Find a range
    while (true) {
        CGSize lpSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:up]}];
        if (lpSize.width >= size.width || lpSize.height >= size.height) {
            break;
        }
        low = up;
        up  = up*2;
    }
    
    // Binary search in the range
    while (true) {
        
        if (up <= low+1)
            return low;
        
        int fontSize = (low + up) / 2;
        
        CGSize lpSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
        if (lpSize.width < size.width && lpSize.height < size.height)
            low = fontSize;
        else
            up  = fontSize;
    }
}

- (void) rendering
{
    if (!self.text)
        return;
    
    Bitmap* bitmap = new Bitmap(self.view.bounds.size.width, self.view.bounds.size.height);
    
    TextProcessor textProcessor([text UTF8String]);
    textProcessor.process();

    std::vector<std::pair<std::string, int> >* wordsVector = textProcessor.newWordsVectorSortedByCount();
    std::vector<std::pair<std::string, int> >::iterator iter;
    
    if (wordsVector->size() <= 0) {
        delete wordsVector;
        return;
    }
    
    float maxFontSize = [self fontSizeOfString:[NSString stringWithUTF8String:wordsVector->begin()->first.c_str()]
                           withConstrainedSize:CGSizeMake(self.view.bounds.size.width  / 2.0f,
                                                          self.view.bounds.size.height / 2.0f)];
    
    float fontSizeRatio = maxFontSize / wordsVector->begin()->second;
    
    for (iter = wordsVector->begin(); iter!=wordsVector->end(); iter++)
    {
        NSString* word = [NSString stringWithUTF8String: iter->first.c_str()];
        
        UIFont* font = [UIFont systemFontOfSize: roundf((iter->second * fontSizeRatio))];
        
        UIImage* wordImage = [self imageOfString:[NSString stringWithUTF8String: iter->first.c_str()]
                                        WithFont:[UIFont systemFontOfSize: roundf((iter->second * fontSizeRatio))]];
        
        if (!wordImage) {
            break;
        }
        
        const unsigned char* binaryPixel = [self newRawDataOfUIImage:wordImage];
        Bitmap wordBitmap(wordImage.size.width, wordImage.size.height, binaryPixel);
        
        CGRect rect = [self getAvailableRectInBitmap:bitmap ForBitmap:&wordBitmap];
        
        MIRect miRect = { (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height };
        if (miRect.isNull()) {
            continue;
        }
        
        bitmap->addBitmapInRect( miRect, &wordBitmap);
        
        delete []binaryPixel;
        
        // Display string in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            ASTextNode* textNode = [[ASTextNode alloc] init];//WithLayerClass:[_ASDisplayLayer class]];
            textNode.layerBacked = true;
            textNode.frame = rect;
            textNode.attributedString = [[NSAttributedString alloc] initWithString:word attributes:@{NSFontAttributeName:font}];
            [self.textNodeContainer addSubnode:textNode];
            
        });
    }
    
    delete wordsVector;
    delete bitmap;
}

- (CGRect) getAvailableRectInBitmap:(Bitmap*)bitmap ForBitmap:(Bitmap*)bitmapTpAdd
{    
    int count = 0;
    while (count++ < 1000)
    {
        int x = rand() % (int)(self.view.bounds.size.width  - bitmapTpAdd->Width() + 1);
        int y = rand() % (int)(self.view.bounds.size.height - bitmapTpAdd->Height()+ 1);
        
//        if (kDataFlagEmperty == bitmap->dataFlagOfRect({ x, y, ipBitmap->Width(), ipBitmap->Height() }))
        if (bitmap->canAddBitmapAtEmpertyArea( {x, y, bitmapTpAdd->Width(), bitmapTpAdd->Height() }, bitmapTpAdd))
            return CGRectMake(x, y, bitmapTpAdd->Width(), bitmapTpAdd->Height());
    }
    
//    NSLog(@"Fail to get available area");
    
    return CGRectZero;
}


#pragma mark - String Bitmap

- (UIImage*) imageOfString:(NSString *)string WithFont:(UIFont *)font
{
    CGSize size = [string sizeWithFont:font];
    
    if ( CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    [string drawInRect:rect withFont:font];
    
	// UIGraphicsGetImageFromCurrentImageContext() return an autoreleased UIImage
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return image;
}

- (unsigned char*) newRawDataOfUIImage:(UIImage*)image
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width  = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = new unsigned char[height * width * 4];
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    unsigned char *binaryData = new unsigned char[height * width];
    for (int h=0;h<height;h++)
    {
        unsigned char* pBinaryData = binaryData + width*h;
        unsigned char* pRawData = rawData + bytesPerRow * h;
        for (int w=0;w<width;w++) {
            if (pRawData[w*4]==255 && pRawData[w*4+1]==255 && pRawData[w*4+2] == 255) {
                pBinaryData[w] = 0;
            } else {
                pBinaryData[w] = 1;
            }
        }
    }
    
    delete rawData;
    
    return binaryData;
}


@end
