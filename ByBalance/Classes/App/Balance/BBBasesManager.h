//
//  BBBasesManager.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 29/11/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//


@interface BBBasesManager : NSObject
{
}

+ (BBBasesManager *) sharedBBBasesManager;

//
- (void) start;
- (BOOL) isReady;
- (BOOL) isBusy;
- (void) stop;
//
- (void) checkForUpdate;
- (void) updateBasesWithCallback:(void(^)(BOOL,NSString*))callback;

@end
