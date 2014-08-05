//
//  Leaderboard.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Leaderboard.h"
#import "ScrollViewScore.h"

@implementation Leaderboard{
    ScrollViewScore *_scrollViewS;
    CCScrollView *_scrollView;
    CCButton *_backButton;
    CCSprite *_arrow;
    CCNode *_mainMenuN;
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

- (void) didLoadFromCCB{
    
    [MGWU getHighScoresForLeaderboard:@"TwinAllTime" withCallback:@selector(receivedScores:) onTarget:self];
    
    audio = [OALSimpleAudio sharedInstance];
    _scrollViewS = (ScrollViewScore*)_scrollView.contentNode;
    check = true;
    [[CCDirector sharedDirector] purgeCachedData];
    int x = [[NSUserDefaults standardUserDefaults] integerForKey:@"leaderboardBack"];
    if(x == 1){
        _mainMenuN.visible = true;
        _backButton.title = @"";
    }
    else{
        _mainMenuN.visible = false;
        _backButton.title = @"Back";
    }
    [MGWU logEvent:@"Check-Leaderboard"];
}

- (void) onEnter{
    [super onEnter];
    check = true;
    [_arrow runAction:[CCActionJumpBy actionWithDuration:2 position:ccp(0,0) height:20 jumps:4]];
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if(check){
        [_arrow runAction:[CCActionFadeOut actionWithDuration:0.4]];
        check = false;
    }
}

- (NSString*) thisSunday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *today = [NSDate date];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:today];
    //1 is sunday
    [components setWeekday:1];
    if([[calendar dateFromComponents:components] compare: today] == NSOrderedDescending){
        [components setWeek:[components week]-1];
    }
    
    NSDate *hehehe = [calendar dateFromComponents:components];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    return [dateFormat stringFromDate:hehehe];
    //return @"20-07-2014"   something like that
}

- (NSString*) thisDate{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    return [dateFormat stringFromDate:today];
}

- (void) backToMain{
    int x = [[NSUserDefaults standardUserDefaults] integerForKey:@"leaderboardBack"];
    CCScene *scene;
    switch (x) {
        case 0:
            scene = [CCBReader loadAsScene:@"StartScene"];
            break;
            
        case 1:
            scene = [CCBReader loadAsScene:@"ModeSelectScene"];
            break;
            
        default:
            break;
    }
    [audio playEffect:@"Sound/zap1.mp3"];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.2]];
}

- (void) allTimeScore{
    [audio playEffect:@"Sound/zap1.mp3"];
    [MGWU getHighScoresForLeaderboard:@"TwinAllTime" withCallback:@selector(receivedScores:) onTarget:self];
}

- (void) weeklyScore{
    [audio playEffect:@"Sound/zap1.mp3"];
    [MGWU getHighScoresForLeaderboard:[NSString stringWithFormat:@"Twin-Weekly-%@",[self thisSunday]] withCallback:@selector(receivedScores:) onTarget:self];
    [MGWU logEvent:@"Check-Leaderboard-Weekly"];
}

- (void) dailyScore{
    [audio playEffect:@"Sound/zap1.mp3"];
    [MGWU getHighScoresForLeaderboard:[NSString stringWithFormat:@"Twin-Daily-%@",[self thisDate]] withCallback:@selector(receivedScores:) onTarget:self];
    [MGWU logEvent:@"Check-Leaderboard-Daily"];
}

- (void) receivedScores:(NSDictionary*)scores
{
    [_scrollViewS updateBoard:scores];
}

@end
