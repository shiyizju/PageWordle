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
#import <unordered_set>
#import <vector>
#import <string>


std::unordered_map<std::string, std::unordered_set<std::string> > omitDict = {
    std::pair<std::string, std::unordered_set<std::string> >("en", {
        "be", "do", "have"
    }),
    std::pair<std::string, std::unordered_set<std::string> >("zh-Hans", {
        "因为", "所以", "可能", "我们", "可以", "不同", "对于", "这个", "如果"
    })
};


@interface LinguisticProcessor () {
    NSDictionary* _omitDictionary;
}
@end


@implementation LinguisticProcessor

// Simple and Naive checking since lexical tagging is not support for Chinese, and not perfect.
- (bool) shouldOmitWord:(NSString*)word forLanguage:(NSString*)language {
    
    if ([word length] <= 1) {
        return true;
    }
    
    std::unordered_map<std::string, std::unordered_set<std::string> >::iterator iter = omitDict.find([language UTF8String]);
    if (iter!=omitDict.end()) {
        if (iter->second.find([word UTF8String]) != iter->second.end()) {
            return true;
        }
    }
    return false;
}

// Linguistical processing and get the word count
- (NSArray*) wordsWithRawText:(NSString *)rawText
{
    __block std::unordered_map<std::string, int> tokenCount;
    __block std::unordered_map<std::string, int>::iterator iter;
    
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSArray* tagSchemes = @[NSLinguisticTagSchemeLanguage, NSLinguisticTagSchemeLemma, NSLinguisticTagSchemeNameTypeOrLexicalClass];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagSchemes options:options];
    tagger.string = rawText;
    
    [tagger enumerateTagsInRange:NSMakeRange(0, [rawText length])
                          scheme:NSLinguisticTagSchemeLanguage
                         options:options
                      usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop)
     {
         NSString *token = [rawText substringWithRange:tokenRange];
         NSString *lemma = nil;
         
         if ([tag isEqualToString:@"zh-Hans"]) {
             // For zh-Hans, lexical tagging is not supported yet. Do some Simple and Naive check...
             lemma = token;
         }
         else if ([tag isEqualToString:@"en"]) {
             // For en, get lexical tag.
             NSString* lexicalTag = [tagger tagAtIndex:tokenRange.location scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass tokenRange:NULL sentenceRange:NULL];
             
             if (lexicalTag == NSLinguisticTagNoun) { // || lexicalTag == NSLinguisticTagVerb || lexicalTag == NSLinguisticTagAdjective ) {
                 // Get lemma
                 lemma = [tagger tagAtIndex:tokenRange.location scheme:NSLinguisticTagSchemeLemma tokenRange: NULL sentenceRange:NULL];
                 if (!lemma) {
                     lemma = token;
                 }
             }
             // Name tags
             else if (lexicalTag == NSLinguisticTagPersonalName || lexicalTag == NSLinguisticTagPlaceName || lexicalTag == NSLinguisticTagOrganizationName) {
                 lemma = token;
             }
         }
         
         if ([self shouldOmitWord:lemma forLanguage:tag]) {
             return;
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


@end
