//
//  UIImage.h
//  Wordle
//
//  Created by Xiaosha Quan on 2/1/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Wordle)

+ (UIImage*) imageOfString:(NSString *)string withFont:(UIFont *)font andScale:(CGFloat)scale;

- (unsigned char*) newBinaryBitmap;

@end
