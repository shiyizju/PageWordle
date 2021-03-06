//
//  Bitmap.cpp
//  Wordle
//
//  Created by quan xiaosha on 4/20/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#include "BinarySplitBitmap.h"

EnumDataFlag BinarySplitBitmap::_dataFlagOfRect(MIRect rect, BSPNode* node)
{
//    assert(rect.isInside(node->rect));
    
    if (node->dataFlag == kDataFlagEmperty || node->dataFlag == kDataFlagOccupied)
        return node->dataFlag;
    
    MIRect subRect1 = rect.overlapRect(node->subnode1->rect);
    MIRect subRect2 = rect.overlapRect(node->subnode2->rect);
    
    if (subRect1.isNull() && subRect2.isNull()) {
        assert(false);
    }
    else if (subRect1.isNull()) {
        return _dataFlagOfRect(subRect2, node->subnode2);
    }
    else if (subRect2.isNull()) {
        return _dataFlagOfRect(subRect1, node->subnode1);
    }
    else {
        EnumDataFlag flag1 = _dataFlagOfRect(subRect1, node->subnode1);
        if (flag1 == kDataFlagMixed)
            return kDataFlagMixed;
        
        EnumDataFlag flag2 = _dataFlagOfRect(subRect2, node->subnode2);
        if (flag2 == kDataFlagMixed)
            return kDataFlagMixed;
        
        return flag1 == flag2 ? flag1 : kDataFlagMixed;
    }
}
// rect: rect in node.
void BinarySplitBitmap::_addBitmapInRect(BSPNode* node, MIRect rect, BinarySplitBitmap* bitmap, MIRect rectInBitmap)
{
    assert(rect.isInside(node->rect));
    assert(node->dataFlag != kDataFlagOccupied);
    
    EnumDataFlag dataFlag = bitmap->dataFlagOfRect(rectInBitmap);
    
    if (dataFlag == kDataFlagEmperty) {
        
        if (node->dataFlag == kDataFlagEmperty) {
            return;
        }
        
        if (rect.isEqual(node->rect)) {
            node->dataFlag = kDataFlagEmperty;
            delete node->subnode1;
            delete node->subnode2;
            node->subnode1 = NULL;
            node->subnode2 = NULL;
            return;
        }
    }
    else if (dataFlag == kDataFlagOccupied) {
        
        if (node->dataFlag == kDataFlagOccupied) {
            return;
        }
        
        if (rect.isEqual(node->rect)) {
            node->dataFlag = kDataFlagOccupied;
            delete node->subnode1;
            delete node->subnode2;
            node->subnode1 = NULL;
            node->subnode2 = NULL;
            return;
        }
    }

    if (node->dataFlag != kDataFlagMixed) {
        splitNode(node);
    }
    
    MIRect subRect1 = rect.overlapRect(node->subnode1->rect);
    MIRect subRect2 = rect.overlapRect(node->subnode2->rect);
    
    int xoffset = rectInBitmap.x - rect.x;
    int yoffset = rectInBitmap.y - rect.y;
    
    if (!subRect1.isNull()) {
        MIRect subBitmapRect1 = { subRect1.x+xoffset, subRect1.y+yoffset, subRect1.width, subRect1.height };
        _addBitmapInRect(node->subnode1, subRect1, bitmap, subBitmapRect1);
    }
    
    if (!subRect2.isNull()) {
        MIRect subBitmapRect2 = { subRect2.x+xoffset, subRect2.y+yoffset, subRect2.width, subRect2.height };
        _addBitmapInRect(node->subnode2, subRect2, bitmap, subBitmapRect2);
    }
}

// rect: rect in bitmap
bool BinarySplitBitmap::_canAddBitmapAtEmpertyArea( BSPNode* node, MIRect rect, BinarySplitBitmap* bitmap, MIRect rectInBitmap)
{
    if (rectInBitmap.isNull()) {
        return true;
    }
    
    if (!rect.isInside(root->rect)) {
        return false;
    }
    
    if (node->dataFlag == kDataFlagEmperty) {
        return true;
    }
    
    if (node->dataFlag == kDataFlagOccupied) {
        return false;
    }
    
    MIRect subRect1 = rect.overlapRect(node->subnode1->rect);
    MIRect subRect2 = rect.overlapRect(node->subnode2->rect);
        
    int xoffset = rectInBitmap.x - rect.x;
    int yoffset = rectInBitmap.y - rect.y;
        
    if (!subRect1.isNull()) {
        MIRect subBitmapRect1 = { subRect1.x+xoffset, subRect1.y+yoffset, subRect1.width, subRect1.height };
        if (!_canAddBitmapAtEmpertyArea(node->subnode1, subRect1, bitmap, subBitmapRect1)) {
            return false;
        }
    }
        
    if (!subRect2.isNull()) {
        MIRect subBitmapRect2 = { subRect2.x+xoffset, subRect2.y+yoffset, subRect2.width, subRect2.height };
        if (!_canAddBitmapAtEmpertyArea(node->subnode2, subRect2, bitmap, subBitmapRect2)) {
            return false;
        }
    }
        
    return true;
}

void BinarySplitBitmap::splitNode(BSPNode* node)
{
    assert(!node->subnode1 && !node->subnode2);
    assert(node->dataFlag!=kDataFlagMixed);
    
    MIRect subRect1, subRect2;
    MIRect rect = node->rect;
    
    if (rect.width > rect.height) {
        subRect1 = { rect.x, rect.y, rect.width/2, rect.height };
        subRect2 = { rect.x + subRect1.width, rect.y, rect.width - subRect1.width, rect.height };
    }
    else {
        subRect1 = { rect.x, rect.y, rect.width, rect.height/2 };
        subRect2 = { rect.x, rect.y + subRect1.height, rect.width, rect.height - subRect1.height };
    }
    
    node->subnode1 = new BSPNode(subRect1);
    node->subnode1->dataFlag = node->dataFlag;
    
    node->subnode2 = new BSPNode(subRect2);
    node->subnode2->dataFlag = node->dataFlag;
    
    node->dataFlag = kDataFlagMixed;
}

void BinarySplitBitmap::initNodeWithPixelData(BSPNode* node, const unsigned char* pixelData, int widthStep)
{
    EnumDataFlag dataFlag = _dataFlagOfRectWithPixelData(node->rect, pixelData, widthStep);
    
    if (dataFlag == kDataFlagEmperty) {
        node->dataFlag = kDataFlagEmperty;
    }
    else if (dataFlag == kDataFlagOccupied) {
        node->dataFlag = kDataFlagOccupied;
    }
    else {
        splitNode(node);
        
        initNodeWithPixelData(node->subnode1, pixelData, widthStep);
        initNodeWithPixelData(node->subnode2, pixelData, widthStep);
    }
}

EnumDataFlag BinarySplitBitmap::_dataFlagOfRectWithPixelData(MIRect rect, const unsigned char* pixelData, int widthStep)
{
    bool findEmperty  = false;
    bool findOccupied = false;
    
    for (int y=rect.y; y<rect.y+rect.height; y++) {
        
        const unsigned char* pdata = pixelData + y*widthStep;
        
        for (int x=rect.x; x<rect.x+rect.width; x++) {
            
            if (pdata[x] == 0) {
                findEmperty = true;
            }
            else {
                findOccupied = true;
            }
            
            if (findEmperty && findOccupied) {
                return kDataFlagMixed;
            }
        }
    }
    
    if (findEmperty) {
        return kDataFlagEmperty;
    }
    
    return kDataFlagOccupied;
}


