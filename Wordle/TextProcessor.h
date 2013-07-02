//
//  TextProcessor.h
//  Wordle
//
//  Created by Quan, Xiaosha on 4/18/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#ifndef __Wordle__TextProcessor__
#define __Wordle__TextProcessor__

#include <iostream>
#include <string>
#include <map>
#include <vector>

class TextProcessor
{
    char* text;
    int length;
    int pos;
    
    char token[256];
    
    std::map<std::string, int> wordmap;
    
    static const char uselessTokens[][256];
    
public:
    TextProcessor(const char* ipText)
    {
        length = strlen(ipText);
        text = new char[length+1];
        
        memset(text, 0, sizeof(char)*length+1);
        
        pos = 0;
        
        memcpy(text, ipText, length);
    }
    
    ~TextProcessor()
    {
        delete []text;
    }
    
    void process();
    
    std::vector<std::pair<std::string, int> >* newWordsVectorSortedByCount();

private:
    bool getNextToken();
    
    bool isCharacter(char c)
    {
        if ((c>='a' && c<='z') || (c>='A' && c<='Z'))
            return true;
        
        return false;
    }
    
    bool isUselessToken();
};

#endif /* defined(__Wordle__TextProcessor__) */
