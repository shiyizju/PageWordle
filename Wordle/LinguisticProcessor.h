//
//  LinguisticProcessor.h
//  Wordle
//
//  Created by Xiaosha Quan on 1/22/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinguisticProcessor : NSObject
- (NSArray*) wordsWithRawText:(NSString*)rawText;
@end
