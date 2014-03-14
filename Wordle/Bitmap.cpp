//
//  Bitmap.cpp
//  Wordle
//
//  Created by quan xiaosha on 4/20/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#include "Bitmap.h"

EnumDataFlag Bitmap::_dataFlagOfRect(MIRect rect, BSPNode* node)
{
//    assert(rect.isInside(node->rect));
    
    if (node->dataFlag == kDataFlagEmperty || node->dataFlag == kDataFlagOccupied)
        return node->dataFlag;
    
    MIRect subRect1 = rect.overlapRect(node->subNode1->rect);
    MIRect subRect2 = rect.overlapRect(node->subNode2->rect);
    
    if (subRect1.isNull() && subRect2.isNull())
        assert(false);
    else if (subRect1.isNull())
    {
        return _dataFlagOfRect(subRect2, node->subNode2);
    }
    else if (subRect2.isNull())
    {
        return _dataFlagOfRect(subRect1, node->subNode1);
    }
    else
    {
        EnumDataFlag flag1 = _dataFlagOfRect(subRect1, node->subNode1);
        if (flag1 == kDataFlagMixed)
            return kDataFlagMixed;
        
        EnumDataFlag flag2 = _dataFlagOfRect(subRect2, node->subNode2);
        if (flag2 == kDataFlagMixed)
            return kDataFlagMixed;
        
        return flag1 == flag2 ? flag1 : kDataFlagMixed;
    }
}

void Bitmap::_addBitmapInRect(MIRect rect, BSPNode* node, MIRect rectInBitmap, Bitmap* bitmap)
{
    EnumDataFlag dataFlag = bitmap->dataFlagOfRect(rectInBitmap);
    
    if (dataFlag == kDataFlagEmperty)
    {
        if (node->dataFlag == kDataFlagEmperty)
            return;
        
        if (rect.isEqual(node->rect))
        {
            node->dataFlag = kDataFlagEmperty;
            delete node->subNode1;
            delete node->subNode2;
            node->subNode1 = NULL;
            node->subNode2 = NULL;
            return;
        }
    }
    else if (dataFlag == kDataFlagOccupied)
    {
        if (node->dataFlag == kDataFlagOccupied)
            return;
        
        if (rect.isEqual(node->rect))
        {
            node->dataFlag = kDataFlagOccupied;
            delete node->subNode1;
            delete node->subNode2;
            node->subNode1 = NULL;
            node->subNode2 = NULL;
            return;
        }
    }

    if (node->dataFlag != kDataFlagMixed)
    {
        node->createSubNode();
        node->dataFlag = kDataFlagMixed;
    }
    
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

bool Bitmap::_canAddBitmapAtEmpertyArea(MIRect rect, BSPNode* node, MIRect rectInBitmap, Bitmap* bitmap)
{
    EnumDataFlag dataFlag = bitmap->dataFlagOfRect(rectInBitmap);
    
    if (node->dataFlag == kDataFlagEmperty)
        return true;
    else if (node->dataFlag == kDataFlagOccupied)
    {
        if (dataFlag == kDataFlagEmperty)
            return true;
        else
            return false;
    }
    else
    {
        if (dataFlag == kDataFlagEmperty)
            return true;
        
        else if (dataFlag == kDataFlagOccupied)
        {
            if (rect.isEqual(node->rect))
                return false;
        }
        
        MIRect subRect1 = rect.overlapRect(node->subNode1->rect);
        MIRect subRect2 = rect.overlapRect(node->subNode2->rect);
        
        int xoffset = rectInBitmap.x - rect.x;
        int yoffset = rectInBitmap.y - rect.y;
        
        if (!subRect1.isNull())
        {
            MIRect subBitmapRect1 = { subRect1.x+xoffset, subRect1.y+yoffset, subRect1.width, subRect1.height };
            
            if (!_canAddBitmapAtEmpertyArea(subRect1, node->subNode1, subBitmapRect1, bitmap))
                return false;
        }
        
        if (!subRect2.isNull())
        {
            MIRect subBitmapRect2 = { subRect2.x+xoffset, subRect2.y+yoffset, subRect2.width, subRect2.height };
            
            if (! _canAddBitmapAtEmpertyArea(subRect2, node->subNode2, subBitmapRect2, bitmap))
                return false;
        }
        
        return true;
    }
    
}




