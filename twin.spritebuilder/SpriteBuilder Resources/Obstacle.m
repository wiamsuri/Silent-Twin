//
//  Obstacle.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle{
    CCNode *_obstacleBlock;
}

//this method check for collision
- (BOOL) checkBlockCollision:(CGRect) dotBox{
    if(CGRectIntersectsRect(dotBox, _obstacleBlock.boundingBox)){
        return true;
    }
    return false;
}

@end
