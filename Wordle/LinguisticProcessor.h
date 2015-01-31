//
//  LinguisticProcessor.h
//  Wordle
//
//  Created by Xiaosha Quan on 1/22/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const LANGUAGE_ENGLISH;
extern NSString* const LANGUAGE_CHINESE;

@interface LinguisticProcessor : NSObject
- (NSArray*) wordsWithRawText:(NSString*)rawText;
- (NSString*) dominantLanguage;
@end
