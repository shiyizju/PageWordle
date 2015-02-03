//
//  RenderingTask.m
//  Wordle
//
//  Created by Xiaosha Quan on 2/1/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import "RenderingTask.h"
#import "BinarySplitBitmap.h"
#import "LinguisticProcessor.h"
#import "Word.h"
#import "UIImage+Wordle.h"

#import <libkern/OSAtomic.h>


@interface RenderingTask () {
    NSString* _rawText;
    CGSize    _size;
    CGFloat   _scale;
    
    OSSpinLock _lock;
}

@end


@implementation RenderingTask

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

- (instancetype) initWithRawText:(NSString *)rawText size:(CGSize)size scale:(CGFloat)scale
{
    self = [super init];
    if (self) {
        _rawText = rawText;
        _size  = size;
        _scale = scale;
        
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void) cancel {
    OSSpinLockLock(&_lock);
    self.isCancelled = true;
    OSSpinLockUnlock(&_lock);
}

- (void) startRenderingWithEnumerationBlock:(void (^)(UIImage*, float, CGRect))enumBlock onFinish:(void (^)(bool))finishBlock
{
    __weak RenderingTask* weakSelf = self;
    dispatch_async([RenderingTask renderingQueue], ^{
        
        RenderingTask* strongSelf = weakSelf;
        LinguisticProcessor* lingProcessor = [[LinguisticProcessor alloc] init];
        
        NSArray* words = [lingProcessor wordsWithRawText:_rawText];
        if (![words count]) {
            return;
        }
        
        float minFontRation;
        if (lingProcessor.dominantLanguage == LANGUAGE_CHINESE) {
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
            prevFontSize  = fontSize;
            prevFontRatio = fontSize / (float)count;
            
            UIFont* font = [UIFont systemFontOfSize:roundf(fontSize)];
            
            UIImage* wordImage = [UIImage imageOfString:word withFont:font andScale:_scale];
            if (!wordImage) {
                break;
            }
            
            CGImageRef wordImageRef = [wordImage CGImage];
            const unsigned char* binaryPixel = [wordImage newBinaryBitmap];
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
            
            // lock for word enumeration
            OSSpinLockLock(&_lock);
            if (strongSelf.isCancelled) {
                // Exit if task is cancelled.
                OSSpinLockUnlock(&_lock);
                break;
            }
            else {
                enumBlock(wordImage, _scale, imageRect);
            }
            OSSpinLockUnlock(&_lock);
        }
        delete bitmap;
        
        OSSpinLockLock(&_lock);
        finishBlock(strongSelf.isCancelled);
        OSSpinLockUnlock(&_lock);
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

@end