//
//  UIImage.m
//  Wordle
//
//  Created by Xiaosha Quan on 2/1/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import "UIImage+Wordle.h"

@implementation UIImage (Wordle)

+ (UIImage*) imageOfString:(NSString *)string withFont:(UIFont *)font andScale:(CGFloat)scale
{
    CGSize size = [string sizeWithAttributes:@{ NSFontAttributeName:font }];
    
    if ( CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
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

- (unsigned char*) newBinaryBitmap
{
    CGImageRef imageRef = [self CGImage];
    
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
