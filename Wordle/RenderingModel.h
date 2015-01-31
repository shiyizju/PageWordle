//
//  Model.h
//  Wordle
//
//  Created by Xiaosha Quan on 1/24/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SingleWordDisplayBlock)(CGImageRef image, float imageScale, CGRect rect);

@interface RenderingModel : NSObject

@property (nonatomic, assign) CGSize size;  // By pixel.
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) NSString* rawText;

- (void) renderingWithDispalyBlock:(SingleWordDisplayBlock)displayBlock;

@end
