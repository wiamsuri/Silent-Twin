//
//  ModeSelectScene.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/22/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ModeSelectScene.h"
#import "NoLivesLeft.h"
#import "Dot.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation ModeSelectScene{
    CCNodeColor *_livesBox;
    CCNodeGradient *_node1forLife;
    CCLabelTTF *_timeLeftSec;
    CCLabelTTF *_timeLeftMin;
    CCLabelTTF *_timeLeftSecdigit2;
    int minAndSec;
    NSTimer *timer;
    int lives;
    
    OALSimpleAudio *audio;
    
    NoLivesLeft *buyMore;
}

//constants for the game.
static const int SECONDSTOWAIT = 300;
static const int MAXLIVES = 7;

- (void) didLoadFromCCB{
    [[CCDirector sharedDirector] purgeCachedData];
    
    audio = [OALSimpleAudio sharedInstance];
    
    //for number of lives left
    //*******LIVES**********
    bool unlimited;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"maimeekeedsoodnaigarnlen"] != nil && [[[NSUserDefaults standardUserDefaults] objectForKey:@"maimeekeedsoodnaigarnlen"] boolValue]){
        unlimited = true;
        _livesBox.visible = false;
        
    }
    else{
        unlimited = false;
    }
    
    NSDictionary *landT = [[NSUserDefaults standardUserDefaults] objectForKey:@"TimeAndLives"];
    NSDate *then = [landT objectForKey:@"timeSinceLastPlay"];
    lives = [[landT objectForKey:@"livesleft"] integerValue];
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:then];
    int additional = interval / SECONDSTOWAIT;
    lives += additional;
    
    
    if(lives < 0){
        NSNumber *temp = [[NSNumber alloc] initWithInt:0];
        NSDictionary *livesandtime = [[NSDictionary alloc] initWithObjectsAndKeys:then, @"timeSinceLastPlay", temp,@"livesleft", nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeAndLives"];
        [[NSUserDefaults standardUserDefaults] setObject:livesandtime forKey:@"TimeAndLives"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if(unlimited){
        lives = MAXLIVES;
    }
    if(lives >= MAXLIVES){
        lives = MAXLIVES;
        _timeLeftSec.string = @"0";
        _timeLeftMin.string = @"0";
        _timeLeftSecdigit2.string = @"0";
        
        NSNumber *temp = [[NSNumber alloc] initWithInt:lives];
        NSDate *temp2 = [NSDate date];
        NSDictionary *livesandtime = [[NSDictionary alloc] initWithObjectsAndKeys:temp2, @"timeSinceLastPlay", temp,@"livesleft", nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeAndLives"];
        [[NSUserDefaults standardUserDefaults] setObject:livesandtime forKey:@"TimeAndLives"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        minAndSec = SECONDSTOWAIT - ((int)interval%SECONDSTOWAIT);
        //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self select:@selector(updateTimeLeft) userInfo:nil repeats:YES];
        [self updateTimeLeft];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:true];
    }
    [self drawTheRedBox];
    
    buyMore = (NoLivesLeft*)[CCBReader load:@"NoLivesLeft"];
    buyMore.position = ccp(160,270);
    buyMore.visible = false;
    [self addChild:buyMore];
    
    //this line can be deleted if touchbegan isnt useful
    self.userInteractionEnabled = true;
}

- (void) drawTheRedBox{
    [_node1forLife removeAllChildren];
    
    for(int i = 0; i<lives; i++){
        Dot *dot = (Dot*)[CCBReader load:@"Dot"];
        dot.position = ccp((i*23)+2,22);
        [_node1forLife addChild:dot];
    }
}

- (void) updateTimeLeft{
    
    if(minAndSec <= 0){
        lives++;
        [audio playEffect:@"Sound/zapTwoTone2.mp3"];
        NSNumber *temp = [[NSNumber alloc] initWithInt:lives];
        NSDate *now = [NSDate date];
        NSDictionary *livesandtime = [[NSDictionary alloc] initWithObjectsAndKeys:now, @"timeSinceLastPlay", temp,@"livesleft", nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeAndLives"];
        [[NSUserDefaults standardUserDefaults] setObject:livesandtime forKey:@"TimeAndLives"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self drawTheRedBox];
        
        if(lives >= MAXLIVES){
            lives = MAXLIVES;
            minAndSec = 0;
            [timer invalidate];
        }
        else{
            minAndSec = SECONDSTOWAIT;
        }
    }
    NSDictionary *landT = [[NSUserDefaults standardUserDefaults] objectForKey:@"TimeAndLives"];
    NSDate *then = [landT objectForKey:@"timeSinceLastPlay"];
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:then];
    minAndSec = SECONDSTOWAIT - ((int)interval%SECONDSTOWAIT);
    _timeLeftSec.string = [NSString stringWithFormat:@"%i", (minAndSec%10)];
    _timeLeftSecdigit2.string = [NSString stringWithFormat:@"%i", (int)((minAndSec%60)/10)];
    _timeLeftMin.string = [NSString stringWithFormat:@"%i", (minAndSec/60)];
    
    minAndSec--;
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    //[timer invalidate];
    //[_node1forLife.children.lastObject removeFromParent];
    //lives++;
    //[self drawTheRedBox];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"maimeekeedsoodnaigarnlen"];
    //OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play sound effect
    //[audio preloadEffect:@"Sounds/zapThreeToneUp.mp3"];
    //[audio playEffect:@"Sounds/zap1.mp3"];
    //[audio stopBg];
}


- (void) backToStart{
    if(!buyMore.visible){
        [timer invalidate];
        [audio playEffect:@"Sound/zap1.mp3"];
        CCScene *scene = [CCBReader loadAsScene:@"StartScene"];
        [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.2]];
    }
}

- (void) endlessMode{
    
    if(!buyMore.visible){
        if(lives >= 1){
            [timer invalidate];
            
            if(lives >= MAXLIVES){
                lives = MAXLIVES - 1;
                minAndSec = SECONDSTOWAIT;
                NSNumber *temp = [[NSNumber alloc] initWithInt:lives];
                NSDate *now = [NSDate date];
                NSDictionary *livesandtime = [[NSDictionary alloc] initWithObjectsAndKeys:now, @"timeSinceLastPlay", temp,@"livesleft", nil];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeAndLives"];
                [[NSUserDefaults standardUserDefaults] setObject:livesandtime forKey:@"TimeAndLives"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                
                NSDate *then = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TimeAndLives"] objectForKey:@"timeSinceLastPlay"];
                NSDate *now = [NSDate date];
                NSTimeInterval interval = [now timeIntervalSinceDate:then];
                int additional = interval / SECONDSTOWAIT;
                lives -= additional;
                lives--;
                NSNumber *temp = [[NSNumber alloc] initWithInt:lives];
                
                NSDictionary *livesandtime = [[NSDictionary alloc] initWithObjectsAndKeys:then, @"timeSinceLastPlay", temp,@"livesleft", nil];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeAndLives"];
                [[NSUserDefaults standardUserDefaults] setObject:livesandtime forKey:@"TimeAndLives"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [self updateTimeLeft];
            [self drawTheRedBox];
            
            [audio playEffect:@"Sound/zap1.mp3"];

            CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
            [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.3]];
        }
        else{
            buyMore.visible = true;
            //[MGWU showMessage:@"You don't have any lives left. Please come back later." withImage:nil];
            //[MGWU sendPushMessage:@"kjhkjlasdhflkjhasdlkjflkasdhflasdhfl" afterMinutes:1 withData:nil];
        }
    }
}

- (void) levelMode{
    if(!buyMore.visible){
        [timer invalidate];
        [audio playEffect:@"Sound/zap1.mp3"];
        CCScene *scene = [CCBReader loadAsScene:@"LevelSelectScene"];
        [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.2]];
    }
}

@end
