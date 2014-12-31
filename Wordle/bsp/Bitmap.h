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
    
    ~Bitmap()
    {
        delete root;
    }

    
private:
    
    EnumDataFlag _dataFlagOfRect(MIRect rect, BSPNode* node);
    
    bool _canAddBitmapAtEmpertyArea(BSPNode* node, MIRect rect, Bitmap* bitmap, MIRect rectInBitmap);
    
    void _addBitmapInRect(BSPNode* node, MIRect rect, Bitmap* bitmap, MIRect rectInBitmap);
    
    void splitNode(BSPNode* node);
    
    void initNodeWithPixelData(BSPNode* node, const unsigned char* pixelData, int widthStep);
    
    EnumDataFlag _dataFlagOfRectWithPixelData(MIRect rect, const unsigned char* pixelData, int widthStep);
    
};


#endif /* defined(__Wordle__Bitmap__) */
