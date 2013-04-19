//
//  SpaceController.h
//  Wordle
//
//  Created by Quan, Xiaosha on 4/19/13.
//  Copyright (c) 2013 Quan Xiaosha. All rights reserved.
//

#ifndef __Wordle__SpaceController__
#define __Wordle__SpaceController__

#include <iostream>
#include <assert.h>

struct SpaceRect
{
    int x, y, w, h;
    
    bool isEqualTo(SpaceRect rect)
    {
        return x==rect.x && y==rect.y && w==rect.w && h==rect.h;
    }
    
    SpaceRect innerRect(SpaceRect rect)
    {
        int left   = rect.x;
        int right  = rect.x + rect.w;
        int bottom = rect.y;
        int top    = rect.y + rect.h;
        
        if (left < x)
            left = x;
        
        if (right > x+w)
            right = x+w;
        
        if (bottom < y)
            bottom = y;
        
        if (top > y+h)
            top = y+h;
        
        SpaceRect result = { left, bottom, right - left, top - bottom };
        return result;
    }
};

class SpaceNode
{
public:
    SpaceRect rect;
    
    SpaceNode* leftSubNode;
    SpaceNode* rightSubNode;

    int dataStatus;     // 0: all available     1: all occupied     2: mixed
    
public:
    SpaceNode(SpaceRect rect, int dataStatus)
    {
        this->rect = rect;
        this->dataStatus = dataStatus;
        
        leftSubNode  = NULL;
        rightSubNode = NULL;
    }
    
    void spliteNode()
    {
        assert(rect.w > 1 || rect.h > 1);
        
        SpaceRect rect1, rect2;
        
        if (rect.w > rect.h)    // Split on x
        {
            rect1.x = rect.x;
            rect1.y = rect.y;
            rect1.w = rect.w / 2;
            rect1.h = rect.h;
            
            rect2.x = rect.x + rect1.w;
            rect2.y = rect.y;
            rect2.w = rect.w - rect1.w;
            rect2.h = rect.h;
        }
        else                    // Split on y
        {
            rect1.x = rect.x;
            rect1.y = rect.y;
            rect1.w = rect.w;
            rect1.h = rect.h / 2;
            
            rect2.x = rect.x;
            rect2.y = rect.y + rect1.h;
            rect2.w = rect.w;
            rect2.h = rect.h - rect1.h;
        }
                
        leftSubNode  = new SpaceNode(rect1, dataStatus);
        rightSubNode = new SpaceNode(rect2, dataStatus);

        dataStatus = 2;
    }
    
    ~SpaceNode()
    {
        delete leftSubNode;
        delete rightSubNode;
    }
};


class SpaceController
{
private:
    SpaceNode* root;
    
    SpaceRect insertBitmapRect;
    const char* insertBitmapData;
    
public:
    SpaceController(int width, int height)
    {
        SpaceRect rect = { 0, 0, width, height };
        
        root = new SpaceNode(rect, 0);
    }
    
    ~SpaceController()
    {
        delete root;
    }
    
    bool canInsertRectangle(SpaceRect rect, const char* data)
    {
        return true;
        
        insertBitmapRect = rect;
        insertBitmapData = data;
    }
    
    void insertRectangle(SpaceRect rect, char* data)
    {
        insertBitmapRect = rect;
        insertBitmapData = data;
        
        insertRectangleToSpaceNode(rect, root);
    }
    
private:
    bool canInsertRectangleToSpaceNode(SpaceRect rect, SpaceNode* node)
    {
        return true;
    }
    
    void insertRectangleToSpaceNode(SpaceRect rect, SpaceNode* node)
    {
        int dataStatus = dataStatusOfInsertBitmapOfRect(rect);
        
        if (dataStatus == 0)
        {
            if (node->dataStatus == 0)  // same, do nothing
                return;
            
            if (rect.isEqualTo(node->rect))    // override
            {
                node->dataStatus = 0;
                delete node->leftSubNode;
                delete node->rightSubNode;
                
                return;
            }
        }
        
        if (dataStatus == 1)
        {
            if (node->dataStatus == 1)  // same, do nothing
                return;
            
            if (rect.isEqualTo(node->rect))    // override
            {
                node->dataStatus = 1;
                delete node->leftSubNode;
                delete node->rightSubNode;

                return;
            }
        }
        
        // Continue spliting
        if ( node->dataStatus !=2 )
            node->spliteNode();
        
        SpaceRect subRect;
        subRect = node->leftSubNode->rect.innerRect(rect);
        if (subRect.w > 0 && subRect.h > 0)
            insertRectangleToSpaceNode(subRect, node->leftSubNode);
        
        subRect = node->rightSubNode->rect.innerRect(rect);
        if (subRect.w > 0 && subRect.h > 0)
            insertRectangleToSpaceNode(subRect, node->rightSubNode);
        
    }

    int dataStatusOfInsertBitmapOfRect(SpaceRect rect)
    {
        int x0 = rect.x - insertBitmapRect.x;
        int y0 = rect.y - insertBitmapRect.y;
        int x1 = x0 + rect.w;
        int y1 = y0 + rect.h;
        
        assert( x0>=0 && y0>=0 );
        
        bool find0 = false;
        bool find1 = false;
        for (int y=y0; y<y1; y++)
        {
            const char* pchar = insertBitmapData + y * insertBitmapRect.w;
            for (int x=x0; x<x1; x++)
            {
                if (pchar[x])
                    find1 = true;
                else
                    find0 = true;
                
                if (find0 && find1)
                    return 2;
            }
        }
        
        if (find0)
            return 0;
        
        if (find1)
            return 1;
        
        return -1;
    }
};


#endif /* defined(__Wordle__SpaceController__) */
