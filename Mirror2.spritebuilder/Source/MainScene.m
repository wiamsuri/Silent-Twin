//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"

@implementation MainScene{
    CCNode *_bnDot;
    CCNode *_tDot;
    CCLabelTTF *_scoreLable;
    CCNode *_middleBlock;
    NSMutableArray *_obstacles;
}

- (id)init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

- (void) didLoadFromCCB{
    _middleBlock.physicsBody.sensor = YES;
    _bnDot.physicsBody.sensor = YES;
    _tDot.physicsBody.sensor = YES;
}

- (void) addObstacle {
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    CGPoint pos = [self convertToWorldSpace:ccp(-20, 0)];
    obstacle.position = pos;
    [obstacle setupRan];
    [self addChild:obstacle];
    [_obstacles addObject:obstacle];
}

//- (void) onEnter{
    
//}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
}

@end
