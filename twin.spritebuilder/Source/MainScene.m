//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"
#import "CheckPoint.h"
#import "Dot.h"
#import "NSUserDefaults+Encryption.h"
#import "NoLivesLeft.h"
#import <AudioToolbox/AudioToolbox.h>

typedef enum{
    normalP,
    trickP,
    movingGapP,
    fastReflexP,
    fastTrickP,
    superRandomP,
    movingAndTrickP,
    movingAndNormalP,
    restP
}GamePhase;

static const int SECONDSTOWAIT = 300;
static const int MAXLIVES = 7;

@implementation MainScene{
    //OALSimpleAudio *audio;
    Dot *_bnDot;
    Dot *_tDot;
    bool bottom;
    bool paused;
    
    CGPoint _anchorTouchPoint;
    CGPoint bnDotIni;
    CGPoint tDotIni;
    CGPoint bnDotOneFrame;
    
    CCNode *_gameOverNode;
    CCNode *_bottomNode;
    CCNode *_topNode;
    CCLabelTTF *_scoreLable;
    CCLabelTTF *_highScore;
    CCLabelTTF *_scoreLableInNode;
    CCNode *_pausedNode;
    
    NSMutableArray *_obstacles;
    NSMutableArray *_checkPointArray;
    
    NSTimeInterval _deltaAcc;
    CGFloat screenSizeH;
    GamePhase _currentGameState;
    int counter;
    int score;
    int highScore;
    bool gameOv;
    
    //obstacles variable
    CGFloat velocity;
    CGFloat interval;
    CGFloat intervalChanger;
    CGFloat gap;
    
    //for lives display
    CCNodeGradient *_node1forLife;
    CCLabelTTF *_timeLeftSec;
    CCLabelTTF *_timeLeftMin;
    CCLabelTTF *_timeLeftSecdigit2;
    int minAndSec;
    NSTimer *timer;
    int lives;
    
    NoLivesLeft *buyMore;
    CCNodeColor *_livesBox;
    
    OALSimpleAudio *audio;
    
    //analytics
    int numberOfTries;
    int highestScoreOfThisRound;
    int totalObstaclesPassed;
}

#pragma mark - Start

//interval between obstacles
static const CGFloat minYValue = 15;


- (id)init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

- (void) didLoadFromCCB{
    
    
    audio = [OALSimpleAudio sharedInstance];
    
    _obstacles = [NSMutableArray array];
    _checkPointArray = [NSMutableArray array];
    
    //load high score
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"heheheHthisisforSlaaa"] == nil){
        [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInt:0] forKey:@"heheheHthisisforSlaaa"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        highScore = 0;
    }
    else{
        NSNumber *hs = [[NSUserDefaults standardUserDefaults] objectForKey:@"heheheHthisisforSlaaa"];
        highScore = [hs integerValue];
    }
    _highScore.string = [NSString stringWithFormat:@"%d", highScore];
    
    //load stuff loll
    screenSizeH = [[CCDirector sharedDirector] viewSize].height;
    
    //load Dots
    _tDot = (Dot*)[CCBReader load:@"Dot"];
    _bnDot = (Dot*)[CCBReader load:@"Dot"];
    _tDot.position = ccp(200,140);
    _bnDot.position = ccp(200,(screenSizeH/2) - 140);
    [_topNode addChild:_tDot];
    [_bottomNode addChild:_bnDot];
    
    //setup stuffs for game
    [self setupGame];
    
    buyMore = (NoLivesLeft*)[CCBReader load:@"NoLivesLeft"];
    buyMore.position = ccp(160,270);
    buyMore.visible = false;
    [self addChild:buyMore];
    
    //for analytics
    numberOfTries = 0;
    highestScoreOfThisRound = 0;
    totalObstaclesPassed = 0;
    
}

//return string for weekly score
- (NSString*) thisSunday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *today = [NSDate date];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:today];
    [components setWeekday:1]; // 1 == Sunday, 7 == Saturday
    if([[calendar dateFromComponents:components] compare: today] == NSOrderedDescending) // if start is later in time than end
    {
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

//endless analytics
- (void) analyticToMGWU:(bool)finish andContinue:(bool) conti{
    NSNumber *triesTaken = [NSNumber numberWithInt:numberOfTries];
    NSNumber *highestThisRound = [NSNumber numberWithInt:highestScoreOfThisRound];
    NSNumber *averageScore = [NSNumber numberWithFloat:((float)totalObstaclesPassed) / numberOfTries];
    NSString *today = [self thisDate];
    NSDictionary *ana = [[NSDictionary alloc] initWithObjectsAndKeys:today, @"Today's-Date",triesTaken, @"Number-Of-Tries", highestThisRound, @"Highest-Score-Before-Giveup", averageScore, @"Average-Score", nil];
    [MGWU logEvent:@"Endless-Report" withParams:ana] ;
}

- (void) setupBoxForLives{
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
    NSTimeInterval intervalforLives = [now timeIntervalSinceDate:then];
    int additional = intervalforLives / SECONDSTOWAIT;
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
        minAndSec = SECONDSTOWAIT - ((int)intervalforLives%SECONDSTOWAIT);
        //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self select:@selector(updateTimeLeft) userInfo:nil repeats:YES];
        [self updateTimeLeft];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:true];
    }
    [self drawTheRedBox];
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
    NSTimeInterval intervalforminsec = [now timeIntervalSinceDate:then];
    minAndSec = SECONDSTOWAIT - ((int)intervalforminsec%SECONDSTOWAIT);
    _timeLeftSec.string = [NSString stringWithFormat:@"%i", (minAndSec%10)];
    _timeLeftSecdigit2.string = [NSString stringWithFormat:@"%i", (int)((minAndSec%60)/10)];
    _timeLeftMin.string = [NSString stringWithFormat:@"%i", (minAndSec/60)];
    minAndSec--;
}

- (void) setupGame{
    score = 0;
    counter = 12;
    velocity = 80;
    interval = 1.15;
    gap = 60;
    gameOv = false;
    paused = false;
    _currentGameState = normalP;
    [audio playBg:@"Sound/8-bit-loop.mp3" loop:TRUE];
    _scoreLable.string = [NSString stringWithFormat:@"%d", score];
}

#pragma mark - Buttons

- (void) retry{
    
    if(!buyMore.visible){
        [audio playEffect:@"Sound/zap1.mp3"];
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
                NSTimeInterval intervalForLives = [now timeIntervalSinceDate:then];
                int additional = intervalForLives / SECONDSTOWAIT;
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
            
            //setup again
            [audio playEffect:@"Sound/zap1.mp3"];
            [self setupGame];
            _gameOverNode.visible = false;
            
            //for analytic
            numberOfTries += 1;
            
            //clear everything
            for(Obstacle *obstacle in _obstacles){
                [obstacle removeFromParent];
            }
            
            for(CheckPoint *checkP in _checkPointArray){
                [checkP removeFromParent];
            }
            
            [[CCDirector sharedDirector] purgeCachedData];
        }
        else{
            buyMore.visible = true;
            
        }
    }
}

- (void) facebookButton{
    if([MGWU isFacebookActive]){
        NSString *captionS = [[NSString alloc] initWithFormat:@"I just got %i points!!" , score];
        [MGWU shareWithTitle:@"Silent Twin" caption:captionS andDescription:@"Come play Silent Twin!"];
    }
    else{
        [MGWU loginToFacebook];
    }
}

- (void) twitterButton{
    if([MGWU isTwitterActive]){
        NSString *captionS = [[NSString alloc] initWithFormat:@"I just got %i points!!" , score];
        [MGWU postToTwitter:captionS];
    }
    else{
        [MGWU showMessage:@"Twitter is not active" withImage:nil];
    }
}

- (void) pausebutton{
    if(!gameOv){
        paused = !paused;
        _pausedNode.visible = paused;
    }
}

- (void) leaderBoardBu{
    if(!buyMore.visible){
        [audio stopBg];
        [timer invalidate];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"leaderboardBack"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [audio playEffect:@"Sound/zap1.mp3"];
        CCScene *scene = [CCBReader loadAsScene:@"Leaderboard"];
        [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.3]];
    }
}

- (void) toModeSelect{
    if(!buyMore.visible){
        [audio stopBg];
        [timer invalidate];
        [audio playEffect:@"Sound/zap1.mp3"];
        CCScene *scene = [CCBReader loadAsScene:@"ModeSelectScene"];
        [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.3]];
    }
}

#pragma mark - Touch

//determine the dot to control
- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    paused = false;
    _pausedNode.visible = false;
    CGPoint touchLocation = [touch locationInNode:self];
    _anchorTouchPoint = touchLocation;
    
    bnDotIni = _bnDot.position;
    tDotIni = _tDot.position;
    
    if(_anchorTouchPoint.y>screenSizeH/2){
        _anchorTouchPoint.y -= screenSizeH/2;
    }
    
    //assign the current part of the screen to the dot on that screen
    if(touchLocation.y < (screenSizeH/2)){
        bottom = true;
    }
    else{
        bottom = false;
    }
    
    
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!gameOv){
        
        CGPoint touchLocation = [touch locationInNode:self];
        
        //follow the dot
        if(bottom){
            
            _bnDot.position = ccp(_bnDot.position.x, (touchLocation.y - _anchorTouchPoint.y) + bnDotIni.y);
            if(_bnDot.position.y + 14 > screenSizeH/2){
                _bnDot.position = ccp(_bnDot.position.x, screenSizeH/2 - 14 );
            }
            if(_bnDot.position.y - 10 < 0){
                _bnDot.position = ccp(_bnDot.position.x, 10 );
            }
            _tDot.position = ccp(_tDot.position.x, screenSizeH/2 - _bnDot.position.y);
            
        }
        else{
            
            _tDot.position = ccp(_tDot.position.x, (touchLocation.y - (screenSizeH/2) - _anchorTouchPoint.y) + tDotIni.y);
            if(_tDot.position.y - 14 < 0){
                _tDot.position = ccp(_tDot.position.x, 14 );
            }
            if(_tDot.position.y + 10 > screenSizeH/2){
                _tDot.position = ccp(_tDot.position.x, screenSizeH/2 - 10 );
            }
            _bnDot.position = ccp(_bnDot.position.x, screenSizeH/2 - _tDot.position.y);
            
        }
    }
}

#pragma mark - Update

- (void) update:(CCTime)delta{
    if(!(gameOv || paused)){
        
        //increment delta for obstacle to be created
        _deltaAcc += delta;
        
        //*****************call the spawner****************
        [self spawner];

        //change the phase
        if(counter == 0){
            if(_currentGameState == restP){
                
                if(score == 12){
                    _currentGameState = movingAndNormalP;
                    counter += 15;
                }
                else{
                    
                    if(score == 27){
                        _currentGameState = movingAndTrickP;
                        counter += 12;
                    }
                    else{
                        if(score == 39){
                            _currentGameState = fastReflexP;
                            velocity = 250;
                            counter += 10;
                        }
                        else{
                            if(score == 49){
                                _currentGameState = fastTrickP;
                                velocity = 220;
                                counter += 8;
                            }
                            else{
                                if(score == 57){
                                    _currentGameState = superRandomP;
                                    velocity = 80;
                                    counter += 12;
                                }
                                else{
                                    [self randomPhase];
                                }
                            }
                        }
                    }
                }
            }
            else{
                _currentGameState = restP;
                counter += 4;
            }
        }
        
        //rotate the dots
        float targetRotation = (_bnDot.position.y - bnDotOneFrame.y)*10;
        if(abs(targetRotation-_bnDot.rotation) > 4){
            if((targetRotation- _bnDot.rotation) > 0){
                _bnDot.rotation = _bnDot.rotation +4;
            }
            else{
                _bnDot.rotation = _bnDot.rotation -4;
            }
        }
        else{
            _bnDot.rotation = _bnDot.rotation + (targetRotation- _bnDot.rotation);
            
        }
        _tDot.rotation = -_bnDot.rotation;
        bnDotOneFrame = _bnDot.position;
        
        //move the obstacle
        for(Obstacle *obstacle in _obstacles){
            obstacle.position = ccp(obstacle.position.x + (velocity*delta), obstacle.position.y);
            
            //move the gap of the obstacle
            if(obstacle.moveAble){
                if(obstacle.isBottom){
                    if(obstacle.goingUp){
                        [obstacle setContentSize:CGSizeMake(obstacle.contentSize.width, obstacle.contentSize.height + 0.5)];
                    }
                    else{
                        [obstacle setContentSize:CGSizeMake(obstacle.contentSize.width, obstacle.contentSize.height - 0.5)];
                    }
                    if(obstacle.contentSize.height < minYValue){
                        obstacle.goingUp = true;
                    }
                    if(obstacle.contentSize.height > screenSizeH/2 - gap - minYValue){
                        obstacle.goingUp = false;
                    }
                }
                else{
                    if(obstacle.goingUp){
                        [obstacle setContentSize:CGSizeMake(obstacle.contentSize.width, obstacle.contentSize.height - 0.5)];
                        [obstacle setPosition:ccp(obstacle.position.x, obstacle.position.y + 0.5)];
                    }
                    else{
                        [obstacle setContentSize:CGSizeMake(obstacle.contentSize.width, obstacle.contentSize.height + 0.5)];
                        [obstacle setPosition:ccp(obstacle.position.x, obstacle.position.y - 0.5)];
                    }
                    if(obstacle.contentSize.height > screenSizeH/2 - gap - minYValue){
                        obstacle.goingUp = true;
                    }
                    if(obstacle.contentSize.height < minYValue){
                        obstacle.goingUp = false;
                    }
                }
            }
            
            //check for collision
            if( ([obstacle checkBlockCollision:_bnDot.boundingBox] && obstacle.parent == _bottomNode) || ([obstacle checkBlockCollision:_tDot.boundingBox] && obstacle.parent == _topNode)){
                _gameOverNode.visible = true;
                gameOv = true;
                
                [audio stopBg];
                [audio playEffect:@"Sound/lowDown.mp3"];
                
                [self setupBoxForLives];
                _scoreLableInNode.string = [NSString stringWithFormat:@"%d", score];
                AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
                
                
                [MGWU submitHighScore:score byPlayer:[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"] forLeaderboard:[NSString stringWithFormat:@"Twin-Weekly-%@",[self thisSunday]]];
                [MGWU submitHighScore:score byPlayer:[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"] forLeaderboard:[NSString stringWithFormat:@"Twin-Daily-%@",[self thisDate]]];
                
                //for analytics only
                if(score > highestScoreOfThisRound){
                    highestScoreOfThisRound = score;
                }
                
                //for sending highscore
                if(score >= highScore){
                    highScore = score;
                    NSNumber *hs1 = [[NSNumber alloc] initWithInt:highScore];
                    [[NSUserDefaults standardUserDefaults] setObject:hs1 forKey:@"heheheHthisisforSlaaa"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    _highScore.string = [NSString stringWithFormat:@"%d", highScore];
                }
                [MGWU submitHighScore:[[[NSUserDefaults standardUserDefaults] objectForKey:@"heheheHthisisforSlaaa"] integerValue] byPlayer:[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"] forLeaderboard:@"TwinAllTime"];
            }
            
            if(obstacle.position.x > 360){
                [obstacle removeFromParent];
            }
        }
        //move the check points too
        for(CheckPoint *checkPointI in _checkPointArray){
            checkPointI.position = ccp(checkPointI.position.x + (velocity*delta), checkPointI.position.y);
            
            
            if(([checkPointI checkCheckpointCollision:_bnDot.boundingBox] && checkPointI.parent == _bottomNode) || ([checkPointI checkCheckpointCollision:_tDot.boundingBox] && checkPointI.parent == _topNode)){
                score += 1;
                
                [audio playEffect:@"Sound/zapThreeToneUp.mp3"];
                //[audio playEffect:@"zapThreeToneUp"];
                
                //for analytics only
                totalObstaclesPassed += 1;
                
                //display score
                _scoreLable.string = [NSString stringWithFormat:@"%d", score];
                
                [checkPointI removeFromParent];
            }
            
            if(checkPointI.position.x > 360){
                [checkPointI removeFromParent];
            }
        }
    }
}

#pragma mark - Phases


- (void) spawner{
    
    //spawn the ostacle using interval of time and the
    //current phase of the game to determine the obstacle
    if(_deltaAcc > interval){
        
        //make the interval even smaller as the player progress
        intervalChanger = 1.15 - (score/4000);
        gap = 60 - (score/85);
        
        
        _deltaAcc = 0;
        counter--;
        switch (_currentGameState) {
            case normalP:
                [self randomNormalObstacles];
                break;
                
            case trickP:
                [self trickObstacles];
                break;
                
            case movingGapP:
                [self randomMoveingObstacle];
                break;
                
            case fastReflexP:
                [self fastObstaclesRanTime];
                break;
                
            case fastTrickP:
                [self fastTrickObstaclesRanTime];
                break;
                
            case superRandomP:
                [self randomEverything];
                break;
                
            case movingAndTrickP:
                [self randomMovingAndTrick];
                break;
                
            case movingAndNormalP:
                [self randomMovingAndNormal];
                break;
                
            case restP:
                interval = intervalChanger;
                break;
                
            default:
                break;
        }
    }
}

//change the phase of the game
- (void) randomPhase{
    //generate random number to choose the phase
    int random = arc4random() % 8;
    switch (random) {
        case 0:
            _currentGameState = superRandomP;
            counter += 12;
            break;
            
        case 1:
            _currentGameState = movingAndTrickP;
            counter += 15;
            break;
            
        case 2:
            _currentGameState = movingAndNormalP;
            counter += 12;
            break;
            
        case 3:
            _currentGameState = fastReflexP;
            velocity = 250;
            counter += 10;
            break;
            
        case 4:
            _currentGameState = fastTrickP;
            velocity = 220;
            counter += 8;
            break;
            
        case 5:
            _currentGameState = superRandomP;
            counter += 12;
            break;
            
        case 6:
            _currentGameState = movingAndTrickP;
            counter += 15;
            break;
            
        case 7:
            _currentGameState = movingAndNormalP;
            counter += 15;
            break;
            
            
        default:
            break;
    }
    
    if(!(_currentGameState == fastReflexP || _currentGameState == fastTrickP)){
        velocity = 80;
        interval = intervalChanger;
    }
}

- (void) randomMoveingObstacle{
    //random top or bottom node
    if((arc4random() %2) ==0){
        [self addObstacleWithOneGap:true withMoveAble:true];
    }
    else{
        [self addObstacleWithOneGap:false withMoveAble:true];
        
    }
}

- (void) randomNormalObstacles{
    
    //random top or bottom node
    if((arc4random() %2) ==0){
        [self addObstacleWithOneGap:true withMoveAble:false];
    }
    else{
        [self addObstacleWithOneGap:false withMoveAble:false];
    }
}

- (void) randomEverything{
    bool upDown = (arc4random() %2) == 0;
    switch (arc4random() % 3) {
        case 0:
            [self addObstacleWithOneGap:upDown withMoveAble:false];
            break;
            
        case 1:
            [self addObstacleWithOneGap:upDown withMoveAble:true];
            break;
            
        case 2:
            [self addTrickObstacle];
            break;
            
        default:
            
            break;
    }
}

- (void) randomMovingAndNormal{
    bool upDown = (arc4random() %2) == 0;
    switch (arc4random() % 2) {
        case 0:
            [self addObstacleWithOneGap:upDown withMoveAble:false];
            break;
            
        case 1:
            [self addObstacleWithOneGap:upDown withMoveAble:true];
            break;
            
        default:
            break;
    }
}

- (void) randomMovingAndTrick{
    bool upDown = (arc4random() %2) == 0;
    switch (arc4random() % 2) {
        case 0:
            [self addObstacleWithOneGap:upDown withMoveAble:true];
            break;
            
        case 1:
            [self trickObstacles];
            break;
            
        default:
            break;
    }
}

- (void) trickObstacles{
    [self addTrickObstacle];
}

- (void) fastObstaclesRanTime{
    bool upDown = (arc4random() %2) == 0;
    interval = (arc4random()%8 +4)/2;
    switch (arc4random() % 2) {
        case 0:
            [self addObstacleWithOneGap:upDown withMoveAble:false];
            break;
            
        case 1:
            [self addObstacleWithOneGap:upDown withMoveAble:true];
            break;
            
        default:
            break;
    }
}

- (void) fastTrickObstaclesRanTime{
    bool upDown = (arc4random() %2) == 0;
    interval = (arc4random()%8 +4)/2;
    switch (arc4random() % 2) {
        case 0:
            [self addObstacleWithOneGap:upDown withMoveAble:true];
            break;
            
        case 1:
            [self trickObstacles];
            break;
            
        default:
            break;
    }
}

#pragma mark - Type of obstacles

//this function add obstacle to screen: put TRUE to put object in the bottomNode
- (void) addObstacleWithOneGap:(BOOL) dOWN withMoveAble:(BOOL) moveA{
    //create the obstacles
    Obstacle *obstacle1 = (Obstacle *)[CCBReader load:@"Obstacle"];
    Obstacle *obstacle2 = (Obstacle *)[CCBReader load:@"Obstacle"];
    CheckPoint *checkPoint = (CheckPoint *)[CCBReader load:@"CheckPoint"];
    
    //setup at random pos
    CGFloat ran = arc4random_uniform( (screenSizeH/2) - (2*minYValue) -gap );
    
    obstacle1.position = ccp(-20, 0);
    obstacle2.position = ccp(-20, gap+minYValue+ran);
    checkPoint.position = ccp(-20, 0);
    
    //setup the size
    [obstacle1 setContentSizeInPoints:CGSizeMake(10, minYValue+ran)];
    [obstacle2 setContentSizeInPoints:CGSizeMake(10, ((screenSizeH/2) -ran - minYValue - gap) )];
    [checkPoint setContentSizeInPoints:CGSizeMake(2, screenSizeH/2)];
    if(moveA){
        obstacle1.moveAble = true;
        obstacle2.moveAble = true;
        if((arc4random() %2) == 0){
            obstacle1.goingUp = true;
            obstacle2.goingUp = true;
        }
        else{
            obstacle1.goingUp = false;
            obstacle2.goingUp = false;
        }
        obstacle1.isBottom = true;
        obstacle2.isBottom = false;
    }
    else{
        obstacle1.moveAble = false;
        obstacle2.moveAble = false;
    }
    
    //when add obstacle   true is adding to bottomNode and false is to the top one
    if(dOWN){
        [_bottomNode addChild:obstacle1];
        [_bottomNode addChild:obstacle2];
        [_bottomNode addChild:checkPoint];
    }
    else{
        [_topNode addChild:obstacle1];
        [_topNode addChild:obstacle2];
        [_topNode addChild:checkPoint];
    }
    
    //add to array so it can move
    [_obstacles addObject:obstacle1];
    [_obstacles addObject:obstacle2];
    [_checkPointArray addObject:checkPoint];
}


- (void) addTrickObstacle{
    //create the obstacles and check point
    Obstacle *obstacle1 = (Obstacle *)[CCBReader load:@"Obstacle"];
    Obstacle *obstacle2 = (Obstacle *)[CCBReader load:@"Obstacle"];
    Obstacle *obstacle3 = (Obstacle *)[CCBReader load:@"Obstacle"];
    Obstacle *obstacle4 = (Obstacle *)[CCBReader load:@"Obstacle"];
    Obstacle *obstacle5 = (Obstacle *)[CCBReader load:@"Obstacle"];
    Obstacle *obstacle6 = (Obstacle *)[CCBReader load:@"Obstacle"];
    Obstacle *obstacle7 = (Obstacle *)[CCBReader load:@"Obstacle"];
    CheckPoint *checkPoint = (CheckPoint *)[CCBReader load:@"CheckPoint"];
    
    //setup at random pos
    CGFloat ran1 = arc4random_uniform((screenSizeH/4) -(2*minYValue) -gap);
    CGFloat ran2 = arc4random_uniform((screenSizeH/4) -(2*minYValue) -gap);
    
    obstacle1.position = ccp(-20, 0);
    obstacle2.position = ccp(-20, (screenSizeH/2) - minYValue - ran2);
    obstacle3.position = ccp(-20, minYValue + ran1 + gap);
    obstacle4.position = ccp(-20, 0);
    obstacle5.position = ccp(-20, (screenSizeH/2) - minYValue - ran1);
    obstacle6.position = ccp(-20, minYValue + ran2 + gap);
    obstacle7.position = ccp(-20, (arc4random() %2) * (screenSizeH/4));
    checkPoint.position = ccp(-20, 0);
    
    //setup size
    [obstacle1 setContentSizeInPoints:CGSizeMake(10, minYValue + ran1)];
    [obstacle2 setContentSizeInPoints:CGSizeMake(10, minYValue + ran2)];
    [obstacle3 setContentSizeInPoints:CGSizeMake(10,(screenSizeH/2)-(2*minYValue)-(2*gap)-ran1-ran2)];
    [checkPoint setContentSizeInPoints:CGSizeMake(2, screenSizeH/2)];
    [obstacle4 setContentSizeInPoints:CGSizeMake(10, minYValue + ran2)];
    [obstacle5 setContentSizeInPoints:CGSizeMake(10, minYValue + ran1)];
    [obstacle6 setContentSizeInPoints:CGSizeMake(10,(screenSizeH/2)-(2*minYValue)-(2*gap)-ran1-ran2)];
    [obstacle7 setContentSizeInPoints:CGSizeMake(10, screenSizeH/4)];
    
    
    
    //add to parent
    [_bottomNode addChild:obstacle1];
    [_bottomNode addChild:obstacle2];
    [_bottomNode addChild:obstacle3];
    [_bottomNode addChild:checkPoint];
    
    [_topNode addChild:obstacle4];
    [_topNode addChild:obstacle5];
    [_topNode addChild:obstacle6];
    
    if((arc4random() %2) == 0){
        [_topNode addChild:obstacle7];
    }
    else{
        [_bottomNode addChild:obstacle7];
    }
    
    //add to array so it can move
    [_obstacles addObject:obstacle1];
    [_obstacles addObject:obstacle2];
    [_obstacles addObject:obstacle3];
    [_obstacles addObject:obstacle4];
    [_obstacles addObject:obstacle5];
    [_obstacles addObject:obstacle6];
    [_obstacles addObject:obstacle7];
    [_checkPointArray addObject:checkPoint];
}

@end
