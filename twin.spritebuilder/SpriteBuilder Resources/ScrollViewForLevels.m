//
//  ScrollViewForLevels.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ScrollViewForLevels.h"

@implementation ScrollViewForLevels{
    CCNode *_buttonNode;
    OALSimpleAudio *audio;
}

- (void) didLoadFromCCB{
    audio = [OALSimpleAudio sharedInstance];

    for(CCButton *button in _buttonNode.children){
        if([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"level%@boolcheck", button.name]]){
            [button setState:CCControlStateNormal];
        }
        else{
            [button setState:CCControlStateDisabled];
            [button setLabelOpacity:0.6 forState:CCControlStateDisabled];
        }
    }
    [[CCDirector sharedDirector] purgeCachedData];
}

- (void) toLevelPlay{
    [audio playEffect:@"Sound/zap1.mp3"];
    CCScene *levelScene = [CCBReader loadAsScene:@"LevelGamePlayScene"];
    [[CCDirector sharedDirector] replaceScene:levelScene withTransition:[CCTransition transitionFadeWithDuration:0.3]];
}

- (void) toLevel1{
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel2{
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel3{
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel4{
    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel5{
    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel6{
    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel7{
    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel8{
    [[NSUserDefaults standardUserDefaults] setInteger:8 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel9{
    [[NSUserDefaults standardUserDefaults] setInteger:9 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel10{
    [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel11{
    [[NSUserDefaults standardUserDefaults] setInteger:11 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel12{
    [[NSUserDefaults standardUserDefaults] setInteger:12 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel13{
    [[NSUserDefaults standardUserDefaults] setInteger:13 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel14{
    [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel15{
    [[NSUserDefaults standardUserDefaults] setInteger:15 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

- (void) toLevel16{
    [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toLevelPlay];
}

@end
