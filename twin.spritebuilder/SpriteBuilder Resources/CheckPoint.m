//
//  CheckPoint.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CheckPoint.h"

@implementation CheckPoint{
    CCNode *_checkPointBlock;
}

//this method check for collision
- (BOOL) checkCheckpointCollision:(CGRect) dotB{
    if(CGRectIntersectsRect(dotB, _checkPointBlock.boundingBox)){
        return true;
    }
    return false;
}

@end
