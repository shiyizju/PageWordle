//
//  Word.m
//  Wordle
//
//  Created by Xiaosha Quan on 1/22/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import "Word.h"

@implementation Word

- (instancetype) initWithText:(NSString *)text Count:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.wordText = text;
        self.count = count;
    }
    return self;
}

@end
