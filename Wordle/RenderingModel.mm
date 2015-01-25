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
#import "UIImage+RawData.h"


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
        
        BinarySplitBitmap* bitmap = new BinarySplitBitmap(_canvasSize.width, _canvasSize.height);
        
        float prevFontSize = [self fontSizeOfString:[(Word*)[words firstObject] wordText] constraintSize:CGSizeMake(_canvasSize.width/2.0f, _canvasSize.height/2.0f)];
        float prevFontRatio = prevFontSize / (float)[(Word*)[words firstObject] count];
        
        for (NSInteger i=0; i < [words count]; i++) {
            
            NSString* word  = [(Word*)[words objectAtIndex:i] wordText];
            NSInteger count = [(Word*)[words objectAtIndex:i] count];
            
            float fontSize = count * prevFontRatio;
            if (fontSize < prevFontSize * 0.6) {
                fontSize = prevFontSize * 0.6;
            }
            prevFontSize = fontSize;
            prevFontRatio = fontSize / (float)count;
            
            UIFont* font = [UIFont systemFontOfSize:roundf(fontSize)];
            
            UIImage* wordImage = [self imageOfString:word WithFont:font];
            if (!wordImage) {
                break;
            }
            
            const unsigned char* binaryPixel = [wordImage newRawData];
            
            BinarySplitBitmap wordBitmap(wordImage.size.width, wordImage.size.height, binaryPixel);
            
            CGRect rect = [self getAvailableRectInBitmap:bitmap ForBitmap:&wordBitmap];
            
            MIRect miRect = { (int)roundf(rect.origin.x), (int)roundf(rect.origin.y), (int)roundf(rect.size.width), (int)round(rect.size.height) };
            if (miRect.isNull()) {
                continue;
            }
            
            bitmap->addBitmapInRect( miRect, &wordBitmap);
            
            delete []binaryPixel;
            
            displayBlock(word, font, rect);
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
        
        int x = rand() % (int)(_canvasSize.width  - bitmapTpAdd->Width() + 1);
        int y = rand() % (int)(_canvasSize.height - bitmapTpAdd->Height()+ 1);
        
//        if (kDataFlagEmperty == bitmap->dataFlagOfRect({x, y, bitmapTpAdd->Width(), bitmapTpAdd->Height() })) {
        if (bitmap->canAddBitmapAtEmpertyArea( {x, y, bitmapTpAdd->Width(), bitmapTpAdd->Height() }, bitmapTpAdd)) {
            return CGRectMake(x, y, bitmapTpAdd->Width(), bitmapTpAdd->Height());
        }
    }
    //    NSLog(@"Fail to get available area");
    return CGRectZero;
}

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

@end
