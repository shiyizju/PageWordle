//
//  TextProcessor.cpp
//  Wordle
//
//  Created by Quan, Xiaosha on 4/18/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#include "TextProcessor.h"

using namespace std;

bool comparePair(std::pair<std::string, int> p1, std::pair<std::string, int> p2)
{
    return p1.second > p2.second;
}

const char TextProcessor::uselessTokens[][256] = {
    "a", "also", "am", "an", "and", "are", "as", "at",
    "by", "be",
    "can",
    "for", "from",
    "had", "has", "have", "he", "him",
    "i", "in", "into", "is", "it", "its",
    "of", "on", "or", "out",
    "she", "so",
    "that", "the", "their", "there", "they", "this", "to", "too",
    "was", "with", "were",
    0,
};

bool TextProcessor::isUselessToken()
{
    if (strlen(token)<=1)
        return true;
        
    for (int i=0;uselessTokens[i][0];i++)
    {
        if (strcmp(uselessTokens[i], token) == 0)
            return true;
    }
    
    return false;
}

bool TextProcessor::getNextToken()
{
    memset(token, 0, sizeof(char)*256);
    
    int len = 0;
    for (;;pos++)
    {
        if (text[pos]=='\0')
            break;
        
        if (isCharacter(text[pos]) || text[pos] == '-')
            token[len++] = tolower(text[pos]);
        else if (len!=0)    // have started finding token
        {
            break;
        }
        // haven't started, continue.
    }
    return len!=0;
}


void TextProcessor::process()
{
    wordmap.clear();
    while (getNextToken())
    {
        if (isUselessToken())
            continue;
        
        std::string str = token;
        std::map<std::string, int>::iterator iter = wordmap.find(str);
        if (iter == wordmap.end())
            wordmap.insert(std::pair<std::string, int>(str, 1));
        else
            iter->second++;
    }
}

vector<pair<string, int> >* TextProcessor::newWordsVectorSortedByCount()
{
    vector<pair<string, int> >* words = new std::vector<std::pair<std::string, int> >(wordmap.begin(), wordmap.end());
    
    std::sort(words->begin(), words->end(), comparePair);
    
    return words;
}