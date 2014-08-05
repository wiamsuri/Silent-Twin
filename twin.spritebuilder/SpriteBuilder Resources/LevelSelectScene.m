//
//  LevelSelectScene.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LevelSelectScene.h"

@implementation LevelSelectScene{
    CCSprite *_arrow;
    bool check;
    OALSimpleAudio *audio;
}

- (id)init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

- (void) onEnter{
    [super onEnter];
    audio = [OALSimpleAudio sharedInstance];
    check = true;
    [_arrow runAction:[CCActionJumpBy actionWithDuration:2 position:ccp(0,0) height:20 jumps:4]];
}

- (void) backToMain{
    [audio playEffect:@"Sound/zap1.mp3"];
    CCScene *scene = [CCBReader loadAsScene:@"ModeSelectScene"];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.2]];
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if(check){
        [_arrow runAction:[CCActionFadeOut actionWithDuration:0.4]];
        check = false;
    }
}

@end
