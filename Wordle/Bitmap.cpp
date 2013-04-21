//
//  Bitmap.cpp
//  Wordle
//
//  Created by quan xiaosha on 4/20/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#include "Bitmap.h"

EnumBitmapRectDataFlag Bitmap::_dataFlagOfRect(MIRect rect, BitmapNode* node)
{
    assert(rect.isInside(node->rect));
    
    if (node->dataFlag == kBitmapRectDataFlagEmperty)
    {
        return kBitmapRectDataFlagEmperty;
    }
    else if (node->dataFlag == kBitmapRectDataFlagOccupied)
    {
        return kBitmapRectDataFlagOccupied;
    }
    else
    {
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
            EnumBitmapRectDataFlag flag1 = _dataFlagOfRect(subRect1, node->subNode1);
            if (flag1 == kBitmapRectDataFlagMixed)
                return kBitmapRectDataFlagMixed;
            
            EnumBitmapRectDataFlag flag2 = _dataFlagOfRect(subRect2, node->subNode2);
            if (flag2 == kBitmapRectDataFlagMixed)
                return kBitmapRectDataFlagMixed;
            
            return flag1 == flag2 ? flag1 : kBitmapRectDataFlagMixed;
        }
    }
}
