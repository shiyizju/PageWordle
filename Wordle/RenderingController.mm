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
{
    Bitmap* bitmap;
}

- (UIImage*) imageOfString:(NSString*)string WithFont:(UIFont*)font;

- (unsigned char*) newRawDataOfUIImage:(UIImage*)image;

- (CGRect) getAvailableRectWithSize:(CGSize)size;

@end



@implementation RenderingController

- (id) init
{
    self = [super init];
    if (self)
    {
        bitmap = new Bitmap(self.view.bounds.size.width, self.view.bounds.size.height);
    }
    return self;
}

- (void) dealloc
{
    delete bitmap;
    
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
    
    TextProcessor textProcessor([text UTF8String]);
    textProcessor.process();

    std::vector<std::pair<std::string, int> >* wordsVector = textProcessor.newWordsVectorSortedByCount();
    std::vector<std::pair<std::string, int> >::iterator iter;
    
    for (iter = wordsVector->begin(); iter!=wordsVector->end(); iter++)
    {
        NSString* word = [NSString stringWithUTF8String: iter->first.c_str()];
        UIFont*   font = [UIFont systemFontOfSize: iter->second * 10];
        
        UIImage* wordImage = [self imageOfString:word WithFont:font];
        
        CGRect rect = [self getAvailableRectWithSize:[wordImage size]];
        Bitmap wordBitmap(rect.size.width, rect.size.height, kDataFlagOccupied);
        bitmap->addBitmapInRect( { (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height }, &wordBitmap);
        
        [words addObject:word];
        [fonts addObject:font];
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }
    
    [(WordsRenderingView*)self.view setWords:words];
    [(WordsRenderingView*)self.view setFonts:fonts];
    [(WordsRenderingView*)self.view setRects:rects];
}

- (CGRect) getAvailableRectWithSize:(CGSize)size
{
    int count = 0;
    while (count++ < 100)
    {
        int x = rand() % (int)(self.view.bounds.size.width  - size.width);
        int y = rand() % (int)(self.view.bounds.size.height - size.height);
    
        if (kDataFlagEmperty == bitmap->dataFlagOfRect({ x, y, (int)size.width, (int)size.height }))
            return CGRectMake(x, y, size.width, size.height);
    }
    
    NSLog(@"Fail to get available area");
    
    return CGRectZero;
}

- (UIImage*) imageOfString:(NSString *)string WithFont:(UIFont *)font
{
    CGSize size = [string sizeWithFont:font];
    
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
        unsigned char* pchar1 = binaryData + width*h;
        unsigned char* pchar2 = rawData + width*h*4;
        for (int w=0;w<width;w++)
        {
            if (!pchar2[4*w] && !pchar2[4*w+1] && !pchar2[4*w+2])
                pchar1[w] = 0;
            else
                pchar1[w] = 1;
        }
    }
    delete rawData;
    
    return binaryData;
}


@end
