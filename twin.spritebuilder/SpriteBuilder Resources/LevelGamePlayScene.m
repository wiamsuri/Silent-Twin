//
//  LevelGamePlayScene.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LevelGamePlayScene.h"
#import "Obstacle.h"
#import "CheckPoint.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation LevelGamePlayScene{
    CCNode *_bnDot;
    CCNode *_tDot;
    bool bottom;
    
    CGPoint _anchorTouchPoint;
    CGPoint bnDotIni;
    CGPoint tDotIni;
    CGPoint bnDotOneFrame;
    
    CCNode *_gameOverNode;
    CCNode *_LevelClearedNode;
    CCNode *_bottomNode;
    CCNode *_topNode;
    CCLabelTTF *_scoreLable;
    CCButton *_nextLevel;
    
    NSMutableArray *_obstacles;
    NSMutableArray *_checkPointArray;
    
    NSTimeInterval _deltaAcc;
    CGFloat screenSizeH;
    int counter;
    int score;
    int target;
    bool gameOv;
    bool levelCleared;
    
    //obstacles variable
    CGFloat velocity;
    CGFloat interval;
    CGFloat gap;
    
    //for audio
    OALSimpleAudio *audio;
    
    //for analytic
    int numberOfTries;
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
    
    //load stuff
    screenSizeH = [[CCDirector sharedDirector] viewSize].height;
    
    [self setupGame];
    numberOfTries = 0;
}

- (void) setupGame{
    score = 0;
    velocity = 80;
    interval = 1.12;
    gap = 60;
    gameOv = false;
    levelCleared = false;
    _nextLevel.visible = true;
    [audio playBg:@"Sound/8-bit-loop.mp3" loop:TRUE];
    [self setupCounter];
}

- (void) setupCounter{
    
    
    int selected = [[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLevel"];
    switch (selected) {
        case 0:
            
            break;
            
        case 1:
            counter = 8;
            target = 8;
            gap = 70;
            break;
            
        case 2:
            counter = 9;
            target = 9;
            gap = 65;
            break;
            
        case 3:
            counter = 15;
            target = 15;
            break;
            
        case 4:
            counter = 12;
            target = 12;
            break;
            
        case 5:
            counter = 12;
            target = 12;
            break;
            
        case 6:
            counter = 10;
            target = 10;
            interval = 3;
            break;
            
        case 7:
            counter = 7;
            target = 7;
            interval = 3;
            break;
            
        case 8:
            counter = 20;
            target = 20;
            break;
            
        case 9:
            counter = 20;
            target = 20;
            break;
            
        case 10:
            counter = 25;
            target = 25;
            break;
            
        case 11:
            counter = 15;
            target = 15;
            interval = 3;
            break;
            
        case 12:
            counter = 27;
            target = 27;
            break;
            
        case 13:
            counter = 30;
            target = 30;
            interval = 1.0;
            break;
            
        case 14:
            counter = 15;
            target = 15;
            interval = 3;
            break;
            
        case 15:
            counter = 30;
            target = 30;
            interval = 0.95;
            break;
            
        case 16:
            counter = 35;
            target = 35;
            interval = 0.95;
            break;
            
        default:
            break;
    }
}

- (void) analyticToMGWU:(bool)finish andContinue:(bool) conti{
    NSNumber *triesTaken = [NSNumber numberWithInt:numberOfTries];
    NSNumber *thisLevel = [NSNumber numberWithInt:[[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLevel"]];
    NSNumber *completed = [NSNumber numberWithBool:finish];
    NSNumber *continues = [NSNumber numberWithBool:conti];
    NSDictionary *ana = [[NSDictionary alloc] initWithObjectsAndKeys:thisLevel,@"Level-Number", triesTaken, @"Number-Of-Tries",completed,@"Level-Cleared?",continues,@"Continue?", nil];
    [MGWU logEvent:@"Exit-Level-Report" withParams:ana] ;
}

#pragma mark - Buttons

- (void) retry{
    
    //reset values
    [self setupGame];
    numberOfTries += 1;
    _gameOverNode.visible = false;
    [audio playEffect:@"Sound/zap1.mp3"];
    //clear everything
    for(Obstacle *obstacle in _obstacles){
        [obstacle removeFromParent];
    }
    
    for(CheckPoint *checkP in _checkPointArray){
        [checkP removeFromParent];
    }
    [[CCDirector sharedDirector] purgeCachedData];
}

//level already cleared and go back to level select
- (void) backToLevelSelect{
    [self analyticToMGWU:true andContinue:false];
    [audio stopBg];
    [audio playEffect:@"Sound/zap1.mp3"];
    CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:levelSelectScene withTransition:[CCTransition transitionFadeWithDuration:0.3]];
}

//gameovernode
- (void) levelSelectScene{
    [self analyticToMGWU:false andContinue:false];
    [audio stopBg];
    [audio playEffect:@"Sound/zap1.mp3"];
    CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:levelSelectScene withTransition:[CCTransition transitionFadeWithDuration:0.3]];
}

- (void) goToNextLevel{
    [self analyticToMGWU:true andContinue:true];
    [audio stopBg];
    [audio playEffect:@"Sound/zap1.mp3"];
    int x = 1 + [[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLevel"];
    if(x>=17){
        CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelectScene"];
        [[CCDirector sharedDirector] replaceScene:levelSelectScene];
    }
    else{
    [[NSUserDefaults standardUserDefaults] setInteger:x forKey:@"SelectedLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CCScene *nextLevelSelectScene = [CCBReader loadAsScene:@"LevelGamePlayScene"];
    [[CCDirector sharedDirector] replaceScene:nextLevelSelectScene];
    }
}

#pragma mark - Touch

//determine the dot to control
- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
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
    if(!(gameOv || levelCleared)){
        
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
    if(!(gameOv || levelCleared)){
        
        //increment delta for obstacle to be created
        _deltaAcc += delta;
        
        //call the spawner
        [self spawner];
        
        //rotate the dots as they move vertically
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
                AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
                
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
                [checkPointI removeFromParent];
                if(score > target){
                    //display that level is cleared
                    score -= 1;
                    levelCleared = true;
                    _LevelClearedNode.visible = true;
                    [audio stopBg];
                    int y = 1 + [[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLevel"];
                    if(y>=17){
                        _nextLevel.visible = false;
                    }
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"level%iboolcheck" ,y]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
            }
            if(checkPointI.position.x > 360){
                [checkPointI removeFromParent];
            }
        }
        //display score
        _scoreLable.string = [NSString stringWithFormat:@"%d", target - score];
    }
}

#pragma mark - Phases

- (void) spawner{
    
    //spawn the ostacle using interval of time and the
    //current phase of the game to determine the obstacle
    if(_deltaAcc > interval){
        if(counter == 0){
            [self sendOneCheckPoint];
        }
        int storedInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLevel"];
        _deltaAcc = 0;
        counter--;
        if(counter>=0){
            switch (storedInt) {
                case 0:
                    
                    break;
                    
                case 1:
                    [self randomNormalObstacles];
                    break;
                    
                case 2:
                    [self addTrickObstacle];
                    break;
                    
                case 3:
                    [self randomNormalObstacles];
                    break;
                    
                case 4:
                    [self randomMovingObstacle];
                    break;
                    
                case 5:
                    [self trickObstacles];
                    break;
                    
                case 6:
                    [self fastObstaclesRanTime];
                    velocity = 250;
                    break;
                    
                case 7:
                    [self fastTrickObstaclesRanTime];
                    velocity = 230;
                    break;
                    
                case 8:
                    [self randomMovingObstacle];
                    break;
                    
                case 9:
                    [self trickObstacles];
                    break;
                    
                case 10:
                    [self randomNormalAndTrick];
                    break;
                    
                case 11:
                    [self randomIntervalNormalAndTrick];
                    velocity = 220;
                    break;
                    
                case 12:
                    [self randomMovingAndNormal];
                    break;
                    
                case 13:
                    [self randomMovingAndTrick];
                    break;
                    
                case 14:
                    [self randomIntervalMovingObstacle];
                    velocity = 230;
                    break;
                    
                case 15:
                    [self randomEverything];
                    break;
                    
                case 16:
                    if(counter > 20){
                        [self randomMovingAndTrick];
                    }
                    else{
                        [self randomEverything];
                    }
                    break;
                    
                default:
                    break;
            }
            if(counter == 0){
                interval = 0.5;
            }
        }
    }
}

- (void) randomMovingObstacle{
    //random top or bottom node
    if((arc4random() %2) ==0){
        [self addObstacleWithOneGap:true withMoveAble:true];
    }
    else{
        [self addObstacleWithOneGap:false withMoveAble:true];
    }
}

- (void) randomIntervalMovingObstacle{
    
    
    interval = (arc4random()%8 +4)/2;
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

- (void) randomNormalAndTrick{
    bool upDown = (arc4random() %2) == 0;
    switch (arc4random() % 2) {
        case 0:
            [self addObstacleWithOneGap:upDown withMoveAble:false];
            break;
            
        case 1:
            [self addTrickObstacle];
            break;
            
        default:
            break;
    }
}

- (void) randomIntervalNormalAndTrick{
    
    interval = (arc4random()%8 +4)/2;
    bool upDown = (arc4random() %2) == 0;
    switch (arc4random() % 2) {
        case 0:
            [self addObstacleWithOneGap:upDown withMoveAble:false];
            break;
            
        case 1:
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
    
    interval = (arc4random()%8 +4)/2;
    if((arc4random() %2) ==0){
        [self addObstacleWithOneGap:true withMoveAble:false];
    }
    else{
        [self addObstacleWithOneGap:false withMoveAble:false];
        
    }
}

- (void) fastTrickObstaclesRanTime{
    
    interval = (arc4random()%8 +4)/2;
    [self addTrickObstacle];
}

#pragma mark - Type of obstacles

- (void) sendOneCheckPoint{
    CheckPoint *checkPoint = (CheckPoint *)[CCBReader load:@"CheckPoint"];
    
    checkPoint.position = ccp(-20, 0);
    
    [checkPoint setContentSizeInPoints:CGSizeMake(2, screenSizeH/2)];
    
    [_bottomNode addChild:checkPoint];
    [_checkPointArray addObject:checkPoint];
}

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