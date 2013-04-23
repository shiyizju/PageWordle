//
//  TextProcessor.cpp
//  Wordle
//
//  Created by Quan, Xiaosha on 4/18/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#include "TextProcessor.h"

using namespace std;

void TextProcessor::process()
{
    wordmap.clear();
    while (getNextToken())
    {
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
    vector<pair<string, int> >* words = new std::vector<std::pair<std::string, int> >;
    
    //        std::map<std::string, int>::iterator iter = wordmap.begin();
    //        for (;iter!=wordmap.end();iter++)
    //        {
    //            words->push_back(*iter);
    //        }
    
    //        std::sort(words->begin(), words->end(), &TextProcessor::comparePair);
    return words;
}