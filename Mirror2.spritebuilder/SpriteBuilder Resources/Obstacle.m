//
//  Obstacle.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle{
    CCNode *_topBlock;
    CCNode *_bottomBlock;
}

#define ARC4RANDOM_MAX      0x100000000
//lowest is 20 points from the bottom
static const CGFloat maxYValue = 210;
static const CGFloat minYValue = 20;

- (void)didLoadFromCCB {
    _topBlock.physicsBody.collisionType = @"obs";
    _topBlock.physicsBody.sensor = YES;
    
    _bottomBlock.physicsBody.collisionType = @"obs";
    _bottomBlock.physicsBody.sensor = YES;
}

- (void) setupRan {
    //random number between 0 and 1
    CGFloat ran = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = maxYValue - minYValue;
    
    //resize the content on the obstracle from the random num generated
    _bottomBlock.contentSizeInPoints = CGSizeMake(10, (minYValue + (range * ran)));
    _topBlock.contentSizeInPoints = CGSizeMake(10, -(230-(minYValue + (range * ran))));
}

@end
