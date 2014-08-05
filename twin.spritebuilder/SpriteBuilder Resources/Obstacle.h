//
//  Obstacle.h
//  Mirror2
//
//  Created by Watt Iamsuri on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Obstacle : CCNode

@property(nonatomic,assign) bool moveAble;
@property(nonatomic,assign) bool goingUp;
@property(nonatomic,assign) bool isBottom;

- (BOOL) checkBlockCollision:(CGRect) dotBox;

@end
