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
#import "WordsRenderingView.h"


@interface RenderingController ()

- (UIImage*) imageOfString:(NSString*)string WithSize:(CGSize)size WithFont:(UIFont*)font;

- (unsigned char*) newRawDataOfUIImage:(UIImage*)image;

@end



@implementation RenderingController

/*
- (id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}*/

- (void) dealloc
{
    [super dealloc];
}

- (void) loadView
{
    self.view = [[[WordsRenderingView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
}

- (void) renderingWithInputText:(NSString *)text
{
    NSMutableArray* words = [NSMutableArray array];
    NSMutableArray* fonts = [NSMutableArray array];
    NSMutableArray* rects = [NSMutableArray array];
    
    Bitmap bitmap(self.view.bounds.size.width, self.view.bounds.size.height);

    TextProcessor textProcessor([text UTF8String]);
    textProcessor.process();

    std::vector<std::pair<std::string, int> >* wordsVector = textProcessor.newWordsVectorSortedByCount();
    std::vector<std::pair<std::string, int> >::iterator iter;
    
    for (iter = wordsVector->begin(); iter!=wordsVector->end(); iter++)
    {
        NSString* word = [NSString stringWithUTF8String: iter->first.c_str()];
        UIFont*   font = [UIFont systemFontOfSize: iter->second * 10];
        
        CGSize wordSize = [word sizeWithFont:font];
        
        float x = rand() % (int)(self.view.bounds.size.width  - wordSize.width);
        float y = rand() % (int)(self.view.bounds.size.height - wordSize.height);

        CGRect rect = CGRectMake(x, y, wordSize.width, wordSize.height);
        
        [words addObject:word];
        [fonts addObject:font];
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }
    
    [(WordsRenderingView*)self.view setWords:words];
    [(WordsRenderingView*)self.view setFonts:fonts];
    [(WordsRenderingView*)self.view setRects:rects];
}

- (UIImage*) imageOfString:(NSString *)string WithSize:(CGSize)size WithFont:(UIFont *)font
{
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
	CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
	CGContextFillRect(context, rect);
    
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
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}


@end
