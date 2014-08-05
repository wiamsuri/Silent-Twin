//
//  NoLivesLeft.m
//  Twin
//
//  Created by Watt Iamsuri on 7/31/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NoLivesLeft.h"

@implementation NoLivesLeft

- (void) closeB{
    self.visible = false;
}


//for in-app purchase lateron    set button to visible on sprite too..
//- (void) unlockB{
//    [MGWU testBuyProduct:@"com.wiamsuri.twin.unlockLives" withCallback:@selector(boughtProduct:) onTarget:self];
//}
//
//- (void) boughtProduct:(NSString*) string{
//    if(string == nil){
//        
//    }
//    else{
//        
//        NSNumber *unlimitedBool = [[NSNumber alloc] initWithBool:true];
//        [[NSUserDefaults standardUserDefaults] setObject:unlimitedBool forKey:@"maimeekeedsoodnaigarnlen"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        CCScene *scene = [CCBReader loadAsScene:@"StartScene"];
//        [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.2]];
//        
//    }
//}

@end
