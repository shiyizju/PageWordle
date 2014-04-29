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
    int right()  { return x + width; }
    int bottom() { return y; }
    int top()    { return y + height; }
    
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
        int left   = x > rect.x ? x : rect.x;
        int right  = x + width  > rect.x + rect.width  ? rect.x + rect.width  : x + width;
        int bottom = y > rect.y ? y : rect.y;
        int top    = y + height > rect.y + rect.height ? rect.y + rect.height : y + height;
        
        return { left, bottom, right - left, top - bottom };
    }
    
    bool operator == (MIRect rect)
    {
        return isEqual(rect);
    }
};



#endif /* defined(__Wordle__MIRect__) */
