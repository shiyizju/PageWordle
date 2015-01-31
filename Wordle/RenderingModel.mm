//
//  Model.m
//  Wordle
//
//  Created by Xiaosha Quan on 1/24/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import "RenderingModel.h"
#import "BinarySplitBitmap.h"
#import "LinguisticProcessor.h"
#import "Word.h"


@interface RenderingModel ()
@property (nonatomic, retain) LinguisticProcessor* linguisticProcessor;
@end


@implementation RenderingModel

@synthesize linguisticProcessor = _linguisticProcessor;
- (LinguisticProcessor*) linguisticProcessor
{
    if (!_linguisticProcessor) {
        _linguisticProcessor = [[LinguisticProcessor alloc] init];
    }
    return _linguisticProcessor;
}

+ (dispatch_queue_t) renderingQueue {
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

- (void) renderingWithDispalyBlock:(SingleWordDisplayBlock)displayBlock
{
    dispatch_async([RenderingModel renderingQueue], ^{
        
        NSArray* words = [self.linguisticProcessor wordsWithRawText:self.rawText];
        if (![words count]) {
            return;
        }
        
        float minFontRation;
        if ([self.linguisticProcessor dominantLanguage] == LANGUAGE_CHINESE) {
            minFontRation = 0.5;
        } else {
            minFontRation = 0.6;
        }
        
        BinarySplitBitmap* bitmap = new BinarySplitBitmap(_size.width * _scale, _size.height * _scale);
        
        float prevFontSize = [self fontSizeOfString:[(Word*)[words firstObject] wordText] constraintSize:CGSizeMake(_size.width/2.0f, _size.height/2.0f)];
        float prevFontRatio = prevFontSize / (float)[(Word*)[words firstObject] count];
        
        for (NSInteger i=0; i < [words count]; i++) {
            
            NSString* word  = [(Word*)[words objectAtIndex:i] wordText];
            NSInteger count = [(Word*)[words objectAtIndex:i] count];
            
            float fontSize = count * prevFontRatio;
            if (fontSize < prevFontSize * minFontRation) {
                fontSize = prevFontSize * minFontRation;
            }
            prevFontSize = fontSize;
            prevFontRatio = fontSize / (float)count;
            
            UIFont* font = [UIFont systemFontOfSize:roundf(fontSize)];
            
            UIImage* wordImage = [self imageOfString:word WithFont:font];
            if (!wordImage) {
                break;
            }
            
            CGImageRef wordImageRef = [wordImage CGImage];
            const unsigned char* binaryPixel = [self newBinaryBitmapOfCGImage:wordImage];
            BinarySplitBitmap wordBitmap((int)CGImageGetWidth(wordImageRef), (int)CGImageGetHeight(wordImageRef), binaryPixel);
            delete []binaryPixel;

            CGRect rect = [self getAvailableRectInBitmap:bitmap ForBitmap:&wordBitmap];
            
            MIRect miRect = { (int)roundf(rect.origin.x), (int)roundf(rect.origin.y), (int)roundf(rect.size.width), (int)round(rect.size.height) };
            if (miRect.isNull()) {
                continue;
            }
            
            bitmap->addBitmapInRect( miRect, &wordBitmap);
            
            CGFloat oneDividScale = 1 / _scale;
            CGRect imageRect = CGRectMake(rect.origin.x * oneDividScale,
                                          rect.origin.y * oneDividScale,
                                          rect.size.width  * oneDividScale,
                                          rect.size.height * oneDividScale);
            
            displayBlock(wordImageRef, _scale, imageRect);
            
        }
        
        delete bitmap;
    });
}

#pragma mark - Private Method

// Find the font size for the word with highest frequency
- (float) fontSizeOfString:(NSString*)string constraintSize:(CGSize)size
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
        if (lpSize.width < size.width && lpSize.height < size.height) {
            low = fontSize;
        } else {
            up  = fontSize;
        }
    }
}

// Currently strategy, random 1000 times, return zero if all fails to get a rect.
- (CGRect) getAvailableRectInBitmap:(BinarySplitBitmap*)bitmap ForBitmap:(BinarySplitBitmap*)bitmapTpAdd
{
    int count = 0;
    while (count++ < 1000) {
        
        int x = rand() % (int)(bitmap->Width()  - bitmapTpAdd->Width() + 1);
        int y = rand() % (int)(bitmap->Height() - bitmapTpAdd->Height()+ 1);
        
        if (bitmap->canAddBitmapAtEmpertyArea( {x, y, bitmapTpAdd->Width(), bitmapTpAdd->Height() }, bitmapTpAdd)) {
            return CGRectMake(x, y, bitmapTpAdd->Width(), bitmapTpAdd->Height());
        }
    }
    //    NSLog(@"Fail to get available area");
    return CGRectZero;
}

- (UIImage*) imageOfString:(NSString *)string WithFont:(UIFont *)font
{
    CGSize size = [string sizeWithAttributes:@{ NSFontAttributeName:font }];
    
    if ( CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, _scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    [string drawInRect:rect withFont:font];
    
    // UIGraphicsGetImageFromCurrentImageContext() return an autoreleased UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (unsigned char*) newBinaryBitmapOfCGImage:(UIImage*)image
{
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width  = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = new unsigned char[height * width * 4];
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    unsigned char *binaryData = new unsigned char[height * width];
    for (int h=0;h<height;h++) {
        unsigned char* pBinaryData = binaryData + width*h;
        unsigned char* pRawData = rawData + bytesPerRow * h;
        for (int w=0;w<width;w++) {
            if (pRawData[w*4]==255 && pRawData[w*4+1]==255 && pRawData[w*4+2] == 255) {
                pBinaryData[w] = 0;
            }
            else {
                pBinaryData[w] = 1;
            }
        }
    }
    delete[] rawData;
    return binaryData;
}

@end
