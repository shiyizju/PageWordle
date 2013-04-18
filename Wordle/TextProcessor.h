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

class TextProcessor
{
    char* text;
    int length;
    int pos;
    
    char token[256];
    
    std::map<std::string, int> wordmap;
    
public:
    TextProcessor(const char* ipText)
    {
        length = strlen(ipText);
        text = new char[length];
        pos = 0;
        
        memcpy(text, ipText, length);
    }
    
    ~TextProcessor()
    {
        delete []text;
    }
    
    void process();
    
    std::map<std::string, int>& getWordMap()
    {
        return wordmap;
    }
    
private:
    bool getNextToken()
    {
        memset(token, 0, sizeof(char)*256);
        
        int len = 0;
        for (;;pos++)
        {
            if (text[pos]=='\0')
                break;
            
            if (isCharacter(text[pos]))
                token[len++] = tolower(text[pos]);
            else if (len!=0)    // have started finding token
            {
                break;
            }
            // haven't started, continue.
        }
        return len!=0;
    }
    
    bool isCharacter(char c)
    {
        if ((c>='a' && c<='z') || (c>='A' && c<='Z'))
            return true;
        
        return false;
    }
};

#endif /* defined(__Wordle__TextProcessor__) */
