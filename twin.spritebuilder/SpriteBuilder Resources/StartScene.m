//
//  StartScene.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "StartScene.h"
#import "NSUserDefaults+Encryption.h"

@implementation StartScene{
    CCNode *_usernameNode;
    CCNode *_usernameInfo;
    CCNode *_nodeforCredit;
    CCTextField *_usernameTextField;
    CCLabelTTF *_currentUsername;
    CCSprite *_node1;
    CCSprite *_node2;
    
    CCButton *_soundButton;
    CCButton *_bgSoundButton;
    OALSimpleAudio *audio;
}

- (void) didLoadFromCCB{
    //this will run only when the game start for the first time
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTSTART"] == nil){
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true]forKey:[NSString stringWithFormat:@"level1boolcheck"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        for(int i = 2 ; i < 17; i++){
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:[NSString stringWithFormat:@"level%iboolcheck" ,i]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        //for life left
        NSDate *now = [NSDate date];
        NSNumber *livesLeft = [[NSNumber alloc] initWithInt:7];
        NSDictionary *livesandtime = [[NSDictionary alloc] initWithObjectsAndKeys:now, @"timeSinceLastPlay", livesLeft,@"livesleft", nil];
        [[NSUserDefaults standardUserDefaults] setObject:livesandtime forKey:@"TimeAndLives"];
        
        //unmuted sound
        NSNumber *muted = [[NSNumber alloc] initWithBool:false];
        audio.effectsMuted = false;
        [[NSUserDefaults standardUserDefaults] setObject:muted forKey:@"mutedSetting"];
        
        NSNumber *bgMuted = [[NSNumber alloc] initWithBool:false];
        audio.bgMuted = false;
        [[NSUserDefaults standardUserDefaults] setObject:bgMuted forKey:@"bgMuted"];
        
        //make this part not run again ever
        [[NSUserDefaults standardUserDefaults] setObject:@"startlana" forKey:@"FIRSTSTART"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //check if username is blank. if yes then ask to enter
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"Username"] == nil || [[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"] isEqual: @""]){
        [_usernameNode runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:ccp(_usernameNode.position.x, 450)]]];
        _usernameNode.visible = true;
    }
    
    _nodeforCredit.visible = false;
    audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"Sound/lowDown.mp3"];
    [audio preloadEffect:@"Sound/zap1.mp3"];
    [audio preloadEffect:@"Sound/zapTwoTone2.mp3"];
    [audio preloadEffect:@"Sound/zapThreeToneUp.mp3"];
    audio.bgVolume = 0.26;
    audio.effectsVolume = 3;
    
    bool muted = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mutedSetting"] boolValue];
    if(muted){
        _soundButton.label.string = @"muted";
    }
    else{
        _soundButton.label.string = @"unmuted";
    }
    bool bgmuted = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bgMuted"] boolValue];
    if(bgmuted){
        _bgSoundButton.label.string = @"muted";
    }
    else{
        _bgSoundButton.label.string = @"unmuted";
    }
}

- (void) onEnter{
    [super onEnter];
    //animate the two box to bounce in
    CGFloat screenSizeH = [[CCDirector sharedDirector] viewSize].height;
    CGFloat screenSizeW = [[CCDirector sharedDirector] viewSize].width;
    CGPoint target = ccp(((float)100/320) * screenSizeW,((float)330/480)*screenSizeH);
    CGPoint target2 = ccp(((float)220/320) * screenSizeW,((float)140/480)*screenSizeH);
    
    [_node1 runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:target]]];
    [_node2 runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:target2]]];
    
}

//to mode select
- (void) toLevelSelectScene{
    if(_usernameInfo.position.y == -120 && _usernameNode.position.y == -120){
        [audio playEffect:@"Sound/zap1.mp3"];
        CCScene *levelSelectScene = [CCBReader loadAsScene:@"ModeSelectScene"];
        [[CCDirector sharedDirector] replaceScene:levelSelectScene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.2]];
        
    }
}

- (void) soundMuteOrUnmute{
    bool muted = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mutedSetting"] boolValue];
    if(muted){
        _soundButton.label.string = @"unmuted";
        audio.effectsMuted = false;
        [audio playEffect:@"Sound/zap1.mp3"];
    }
    else{
        _soundButton.label.string = @"muted";
        audio.effectsMuted = true;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithBool:!muted] forKey:@"mutedSetting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) bgSoundMuteOrUnmute{
    bool muted = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bgMuted"] boolValue];
    if(muted){
        _bgSoundButton.label.string = @"unmuted";
        audio.bgMuted = false;
        [audio playEffect:@"Sound/zap1.mp3"];
    }
    else{
        _bgSoundButton.label.string = @"muted";
        audio.bgMuted = true;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithBool:!muted] forKey:@"bgMuted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) credits{
    _nodeforCredit.visible = true;
}

- (void) closeBCredit{
    _nodeforCredit.visible = false;
}

- (void) usernameEnter{
    NSString *usernameTemp = [_usernameTextField string];
    if(usernameTemp == nil ||  [usernameTemp  isEqual: @""]){
        [MGWU showMessage:@"Please enter something :)" withImage:nil];
    }
    else{
        if([[usernameTemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
            [MGWU showMessage:@"Cannot be only spaces" withImage:nil];
        }
        else{
            
            if([[usernameTemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 16){
                [MGWU showMessage:@"Too long. Sorry :(" withImage:nil];
            }
            else{
                [[NSUserDefaults standardUserDefaults] setObject:usernameTemp forKey:@"Username"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [audio playEffect:@"Sound/zap1.mp3"];
                [_usernameNode runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:ccp(_usernameNode.position.x, -120)]]];
            }
        }
    }
}

- (void) usernameReset{
    _currentUsername.string = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _usernameInfo.visible = true;
    [audio playEffect:@"Sound/zap1.mp3"];
    [_usernameInfo runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:ccp(_usernameNode.position.x, 450)]]];
}

- (void) usernameInfoClose{
    [audio playEffect:@"Sound/zap1.mp3"];
    [_usernameInfo runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:ccp(_usernameNode.position.x, -120)]]];
}

- (void) usernameInfoReset{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Username"];
    [audio playEffect:@"Sound/zap1.mp3"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_usernameInfo runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:ccp(_usernameNode.position.x, -120)]]];
    _usernameNode.visible = true;
    [_usernameNode runAction:[CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:0.85f position:ccp(_usernameNode.position.x, 450)]]];
}

- (void) leaderboardButton{
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"leaderboardBack"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [audio playEffect:@"Sound/zap1.mp3"];
    CCScene *leaderboardScene = [CCBReader loadAsScene:@"Leaderboard"];
    [[CCDirector sharedDirector] replaceScene:leaderboardScene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.2]];
}

@end
