//
//  MIRect.h
//  Wordle
//
//  Created by Quan, Xiaosha on 1/28/14.
//  Copyright (c) 2014 Quan Xiaosha. All rights reserved.
//

#ifndef __Wordle__MIRect__
#define __Wordle__MIRect__

#include <iostream>

class MIRect {
public:
    
    int x, y, width, height;
    
    int left()   { return x; }
    int right()  { return x + width - 1; }
    int bottom() { return y; }
    int top()    { return y + height - 1; }
    
    bool isEqual(MIRect rect)
    {
        return x == rect.x && y == rect.y && width == rect.width && height == rect.height;
    }
    
    bool isInside(MIRect rect)
    {
        return  x >= rect.x &&
        y >= rect.y &&
        x + width  <= rect.x + rect.width &&
        y + height <= rect.y + rect.height;
    }
    
    bool isNull()
    {
        return width <= 0 || height <= 0;
    }
    
    MIRect overlapRect(MIRect rect)
    {
        int left = std::max(this->left(), rect.left());
        int right = std::min(this->right(), rect.right());
        int bottom = std::max(this->bottom(), rect.bottom());
        int top = std::min(this->top(), rect.top());
        
        return { left, bottom, right - left + 1, top - bottom + 1};
    }
    
    bool operator == (MIRect rect)
    {
        return isEqual(rect);
    }
};



#endif /* defined(__Wordle__MIRect__) */
