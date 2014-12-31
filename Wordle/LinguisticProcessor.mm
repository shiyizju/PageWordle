//
//  LinguisticProcessor.m
//  Wordle
//
//  Created by Xiaosha Quan on 1/22/15.
//  Copyright (c) 2015 Quan Xiaosha. All rights reserved.
//

#import "LinguisticProcessor.h"
#import "Word.h"

#import <unordered_map>
#import <vector>
#import <string>

@interface LinguisticProcessor ()

@end



@implementation LinguisticProcessor

// Linguistical processing and get the word count
- (NSArray*) wordsWithRawText:(NSString *)rawText
{
    __block std::unordered_map<std::string, int> tokenCount;
    __block std::unordered_map<std::string, int>::iterator iter;
    
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    tagger.string = rawText;
    
    [tagger enumerateTagsInRange:NSMakeRange(0, [rawText length])
                          scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass
                         options:options
                      usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop)
     {
         NSString *token = [rawText substringWithRange:tokenRange];
//         NSLog(@"%@: %@", token, tag);
         
         if ([token length] <= 1) {
             return;
         }
         
         if (![self usefulTagger:tag]) { // && tag!=NSLinguisticTagVerb && tag!=NSLinguisticTagAdverb) {
             return;
         }
         
         NSString* lemma = nil;
         if ([self isNameTag:tag]) {
             lemma = token;
         }
         else {
             lemma = [tagger tagAtIndex:tokenRange.location scheme:NSLinguisticTagSchemeLemma tokenRange: NULL sentenceRange:NULL];
             if (!lemma) {
                 lemma = token;
             }
         }
         
         iter = tokenCount.find([lemma UTF8String]);
         if (iter == tokenCount.end()) {
             // Does not exist
             tokenCount.insert(std::pair<std::string, int>([lemma UTF8String], 1));
         }
         else {
             iter->second++;
         }
     }];
    
    NSMutableArray* lpWords = [NSMutableArray array];
    
    for (iter = tokenCount.begin(); iter != tokenCount.end(); iter++) {
        Word* word = [[Word alloc] initWithText:[NSString stringWithUTF8String:iter->first.c_str()] Count:iter->second];
        [lpWords addObject:word];
    }
    
    // Sort by count.
    [lpWords sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([(Word*)obj1 count] < [(Word*)obj2 count]) {
            return NSOrderedDescending;
        }
        else if ([(Word*)obj1 count] > [(Word*)obj2 count]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    return lpWords;
}

#pragma mark - Private Method

- (bool) usefulTagger:(NSString*) tag {
    return  tag == NSLinguisticTagNoun              ||
            tag == NSLinguisticTagIdiom             ||
            tag == NSLinguisticTagOrganizationName  ||
            tag == NSLinguisticTagPersonalName      ||
            tag == NSLinguisticTagPlaceName;
}

- (bool) isNameTag:(NSString*) tag {
    return  tag == NSLinguisticTagOrganizationName  ||
            tag == NSLinguisticTagPersonalName      ||
            tag == NSLinguisticTagPlaceName;
}

@end
