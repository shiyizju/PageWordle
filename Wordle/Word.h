//
//  Word.h
//  Wordle
//
//  Created by Xiaosha Quan on 1/22/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject

- (instancetype) initWithText:(NSString*)wordText Count:(NSInteger) count;

@property (nonatomic, strong) NSString* wordText;
@property (nonatomic, assign) NSInteger count;

@end
