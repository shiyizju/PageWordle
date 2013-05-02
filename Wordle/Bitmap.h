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

class BSPBitmapNode
{
    MIRect rect;

    BSPBitmapNode* subNode1;
    BSPBitmapNode* subNode2;
    
    EnumDataFlag dataFlag;
    
    friend class Bitmap;
    
public:
    BSPBitmapNode(MIRect rect)
    {
        this->rect = rect;
        
        subNode1 = NULL;
        subNode2 = NULL;
        
        dataFlag = kDataFlagEmperty;
    }
    
    void createSubNode()
    {
        if (dataFlag == kDataFlagMixed)
        {
            assert(false);
            return;
        }
        
        MIRect subRect1, subRect2;
        
        if (rect.width > rect.height)
        {
            subRect1 = { rect.x, rect.y, rect.width/2, rect.height };
            subRect2 = { rect.x + subRect1.width, rect.y, rect.width - subRect1.width, rect.height };
        }
        else
        {
            subRect1 = { rect.x, rect.y, rect.width, rect.height/2 };
            subRect2 = { rect.x, rect.y + subRect1.height, rect.width, rect.height - subRect1.height };
        }
        
        subNode1 = new BSPBitmapNode(subRect1);
        subNode1->dataFlag = dataFlag;
        
        subNode2 = new BSPBitmapNode(subRect2);
        subNode2->dataFlag = dataFlag;
        
        dataFlag = kDataFlagMixed;
    }

    ~BSPBitmapNode()
    {
        delete subNode1;
        delete subNode2;
    }
};

class Bitmap
{
    BSPBitmapNode* root;
    
    int _w, _h;
    
public:
    Bitmap (int width, int height, EnumDataFlag dataFlag = kDataFlagEmperty)
    {
        root = new BSPBitmapNode( { 0, 0, width, height } );
        
        if (dataFlag != kDataFlagMixed)
            root->dataFlag = dataFlag;
        
        _w = width;
        _h = height;
    }
    
    Bitmap (int width, int height, const unsigned char* pixelData)
    {
        root = new BSPBitmapNode( { 0, 0, width, height } );
        
        _initWithPixelData(root, pixelData, width);
        
        _w = width;
        _h = height;
    }
    
    int width() { return _w; }
    
    int height() { return _h; }
    
    EnumDataFlag dataFlagOfRect(MIRect rect)
    {
        return _dataFlagOfRect(rect, root);
    }
    
    bool canAddBitmapAtEmpertyArea(MIRect rect, Bitmap* bitmap)
    {
        return _canAddBitmapAtEmpertyArea(rect, root, { 0, 0, rect.width, rect.height }, bitmap);
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
    void _initWithPixelData(BSPBitmapNode* node, const unsigned char* pixelData, int widthStep)
    {
        EnumDataFlag dataFlag = _dataFlagOfRectWithPixelData(node->rect, pixelData, widthStep);
        
        if (dataFlag == kDataFlagEmperty)
        {
            node->dataFlag = kDataFlagEmperty;
        }
        else if (dataFlag == kDataFlagOccupied)
        {
            node->dataFlag = kDataFlagOccupied;
        }
        else
        {
            node->createSubNode();
            
            _initWithPixelData(node->subNode1, pixelData, widthStep);
            _initWithPixelData(node->subNode2, pixelData, widthStep);
        }
    }
    
    EnumDataFlag _dataFlagOfRectWithPixelData(MIRect rect, const unsigned char* pixelData, int widthStep)
    {
        bool findEmperty  = false;
        bool findOccupied = false;
        
        for (int y=rect.y; y<rect.y+rect.height; y++)
        {
            const unsigned char* pdata = pixelData + y*widthStep;
            
            for (int x=rect.x; x<rect.x+rect.width; x++)
            {
                if (pdata[x] == 0)
                    findEmperty = true;
                else
                    findOccupied = true;
                
                if (findEmperty && findOccupied)
                    return kDataFlagMixed;
            }
        }
        
        if (findEmperty)
            return kDataFlagEmperty;
        
        return kDataFlagOccupied;
    }
    
    EnumDataFlag _dataFlagOfRect(MIRect rect, BSPBitmapNode* node);
    
    bool _canAddBitmapAtEmpertyArea(MIRect rect, BSPBitmapNode* node, MIRect rectInBitmap, Bitmap* bitmap);
    
    void _addBitmapInRect(MIRect rect, BSPBitmapNode* node, MIRect rectInBitmap, Bitmap* bitmap);
};


#endif /* defined(__Wordle__Bitmap__) */
