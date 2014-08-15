//
//  ScrollViewScore.m
//  Mirror2
//
//  Created by Watt Iamsuri on 7/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ScrollViewScore.h"

@implementation ScrollViewScore{
    CCLabelTTF *_username0;
    CCLabelTTF *_scoreLable0;
}

- (void) updateBoard:(NSDictionary*) scoreData{
    
    NSArray *scoreArray = [scoreData objectForKey:@"all"];
    NSString *usernameResult = @"";
    NSString *scoreResult = @"";
    
    if(scoreArray.count >= 40){
        for(int i = 0; i < 40; i++){
            usernameResult = [usernameResult stringByAppendingString:[[scoreArray objectAtIndex:i] objectForKey:@"name"]];
            usernameResult = [usernameResult stringByAppendingString:@"\n"];
            scoreResult = [scoreResult stringByAppendingString:[NSString stringWithFormat:@"%@",[[scoreArray objectAtIndex:i] objectForKey:@"score"]]];
            scoreResult = [scoreResult stringByAppendingString:@"\n"];
        }
    }
    else{
        for(NSDictionary *usernameI in scoreArray){
            usernameResult = [usernameResult stringByAppendingString:[usernameI objectForKey:@"name"]];
            usernameResult = [usernameResult stringByAppendingString:@"\n"];
            scoreResult = [scoreResult stringByAppendingString:[NSString stringWithFormat:@"%@",[usernameI objectForKey:@"score"]]];
            scoreResult = [scoreResult stringByAppendingString:@"\n"];
        }
    }
    _username0.string = usernameResult;
    _scoreLable0.string = scoreResult;
    
}

@end
