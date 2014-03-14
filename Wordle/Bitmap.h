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
#include "MIRect.h"


enum EnumDataFlag {
    kDataFlagEmperty,
    kDataFlagOccupied,
    kDataFlagMixed,
};

struct BSPNode
{
    MIRect rect;
    BSPNode* subnode1;
    BSPNode* subnode2;
    EnumDataFlag dataFlag;
    
    BSPNode(MIRect iRect): rect(iRect), subnode1(NULL), subnode2(NULL), dataFlag(kDataFlagEmperty) { }
    
    ~BSPNode()
    {
        delete subnode1;
        delete subnode2;
    }
};

class Bitmap
{
    BSPNode* root;
    
    int width;
    int height;
    
public:
    Bitmap (int iWidth, int iHeight, EnumDataFlag dataFlag = kDataFlagEmperty) :
        width(iWidth), height(iHeight)
    {
        assert(dataFlag != kDataFlagMixed);
        
        root = new BSPNode( { 0, 0, width, height } );
        root->dataFlag = dataFlag;
    }
    
    Bitmap (int iWidth, int iHeight, const unsigned char* pixelData) :
        width(iWidth), height(iHeight)
    {
        root = new BSPNode( { 0, 0, width, height } );
        
        initNodeWithPixelData(root, pixelData, width);
    }
    
    int Width() {
        return width;
    }
    
    int Height() {
        return height;
    }
    
    ~Bitmap()
    {
        delete root;
    }
    
    EnumDataFlag dataFlagOfRect(MIRect rect)
    {
        return _dataFlagOfRect(rect, root);
    }
    
    bool canAddBitmapAtEmpertyArea(MIRect rect, Bitmap* bitmap)
    {
        return _canAddBitmapAtEmpertyArea(root, rect, bitmap, { 0, 0, rect.width, rect.height });
    }
    
    void addBitmapInRect(MIRect rect, Bitmap* bitmap)
    {
        _addBitmapInRect(root, rect, bitmap, { 0, 0, rect.width, rect.height });
    }
    
private:
    EnumDataFlag _dataFlagOfRect(MIRect rect, BSPNode* node);
    bool _canAddBitmapAtEmpertyArea(BSPNode* node, MIRect rect, Bitmap* bitmap, MIRect rectInBitmap);
    void _addBitmapInRect(BSPNode* node, MIRect rect, Bitmap* bitmap, MIRect rectInBitmap);
    
private:
    void initNodeWithPixelData(BSPNode* node, const unsigned char* pixelData, int widthStep)
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
            splitNode(node);
            
            initNodeWithPixelData(node->subnode1, pixelData, widthStep);
            initNodeWithPixelData(node->subnode2, pixelData, widthStep);
        }
    }
    
    void splitNode(BSPNode* node)
    {
        assert(!node->subnode1 && !node->subnode2);
        assert(node->dataFlag!=kDataFlagMixed);
        
        MIRect subRect1, subRect2;
        MIRect rect = node->rect;
        
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
        
        node->subnode1 = new BSPNode(subRect1);
        node->subnode1->dataFlag = node->dataFlag;
        
        node->subnode2 = new BSPNode(subRect2);
        node->subnode2->dataFlag = node->dataFlag;
        
        node->dataFlag = kDataFlagMixed;
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
};


#endif /* defined(__Wordle__Bitmap__) */
