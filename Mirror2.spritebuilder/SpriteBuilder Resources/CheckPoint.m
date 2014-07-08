//
//  CheckPoint.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CheckPoint.h"

@implementation CheckPoint

- (void) didLoadFromCCB {
    self.physicsBody.collisionType = @"pass";
    self.physicsBody.sensor = YES;
}

@end
