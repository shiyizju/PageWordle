//
//  Bitmap.h
//  Wordle
//
//  Created by quan xiaosha on 4/20/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#ifndef __Wordle__Bitmap__
#define __Wordle__Bitmap__

#include <iostream>
#include <assert.h>

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

enum EnumDataFlag {
    kDataFlagEmperty,
    kDataFlagOccupied,
    kDataFlagMixed,
//    kDataFlagUnknown
};

class BitmapNode
{
    MIRect rect;

    BitmapNode* subNode1;
    BitmapNode* subNode2;
    
    EnumDataFlag dataFlag;
    
    friend class Bitmap;
    
public:
    
    BitmapNode(MIRect rect)
    {
        this->rect = rect;
        
        subNode1 = NULL;
        subNode2 = NULL;
        
        dataFlag = kDataFlagEmperty;
    }
    
    void createSubNode()
    {
        MIRect subRect1, subRect2;
        
        if (rect.width > rect.height)
        {
            subRect1 = 
        }
    }
    
    BitmapNode()
    {
        delete subNode1;
        delete subNode2;
    }
};

class Bitmap
{
    BitmapNode* root;
    
public:
    Bitmap (int width, int height)
    {
        root = new BitmapNode( { 0, 0, width, height } );
    }
    
    Bitmap (int width, int height, const char* pixelData)
    {
        root = new BitmapNode( { 0, 0, width, height } );
    }
    
    EnumDataFlag dataFlagOfRect(MIRect rect)
    {
        return kDataFlagEmperty;
    }
    
    void addBitmapInRect(MIRect rect, Bitmap* bitmap)
    {
        _addBitmapInRect(rect, root, { 0, 0, rect.width, rect.height }, bitmap);
    }
    
    ~Bitmap()
    {
        delete root;
    }
    
private:

    void createSubnode(BitmapNode node)
    {
        
    }
    
    void _initWithPixelData(BitmapNode* node, const char* pixelData, int widthStep)
    {
        EnumDataFlag dataFlag = _dataFlagOfRectWithPixelData(node->rect, pixelData, widthStep);
        
        if (dataFlag == kDataFlagEmperty)
        {
            
        }
    }
    
    EnumDataFlag _dataFlagOfRectWithPixelData(MIRect rect, const char* pixelData, int widthStep)
    {
        int isEmperty = (pixelData[0]==0);
        
        for (int y=rect.y; y<rect.y+rect.height; y++)
        {
            const char* pdata = pixelData + y*widthStep;
            
            for (int x=rect.x; x<rect.x+rect.width; x++)
            {                
                if (isEmperty != (pdata[x]==0))
                    return kDataFlagMixed;
            }
        }
        
        if (isEmperty)
            return kDataFlagEmperty;
        
        return kDataFlagOccupied;
    }
    
    EnumDataFlag _dataFlagOfRect(MIRect rect, BitmapNode* node);
    
    void _addBitmapInRect(MIRect rect, BitmapNode* node, MIRect rectInBitmap, Bitmap* bitmap)
    {
        EnumDataFlag dataFlag = bitmap->dataFlagOfRect(rectInBitmap);
        
        if (dataFlag == kDataFlagEmperty)
        {
            if (node->dataFlag == kDataFlagEmperty)
                return;
            
            else if (rect.isEqual(node->rect))
                node->dataFlag = kDataFlagEmperty;
        }
        else if (dataFlag == kDataFlagOccupied)
        {
            if (node->dataFlag == kDataFlagOccupied)
                return;
            
            else if (rect.isEqual(node->rect))
                node->dataFlag = kDataFlagOccupied;
        }
        else
        {
            MIRect subRect1 = rect.overlapRect(node->subNode1->rect);
            MIRect subRect2 = rect.overlapRect(node->subNode2->rect);
            
            int xoffset = rectInBitmap.x - rect.x;
            int yoffset = rectInBitmap.y - rect.y;
            
            if (!subRect1.isNull())
            {
                MIRect subBitmapRect1 = { subRect1.x+xoffset, subRect1.y+yoffset, subRect1.width, subRect1.height };
                
                _addBitmapInRect(subRect1, node->subNode1, subBitmapRect1, bitmap);
            }
            
            if (!subRect2.isNull())
            {
                MIRect subBitmapRect2 = { subRect2.x+xoffset, subRect2.y+yoffset, subRect2.width, subRect2.height };
                
                _addBitmapInRect(subRect2, node->subNode2, subBitmapRect2, bitmap);
            }
        }
    }
};


#endif /* defined(__Wordle__Bitmap__) */
