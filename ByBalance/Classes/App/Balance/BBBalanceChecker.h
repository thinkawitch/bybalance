//
//  BBBalanceChecker.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderDelegate.h"

@class BBMAccount;

@interface BBBalanceChecker : NSObject <BBLoaderDelegate>
{
    
@private
    NSObject * syncFlag1;
    NSObject * syncFlag2;
    NSOperationQueue * queue;
    
    
    NSTimer * timer;
    BOOL bgUpdate;
    CFTimeInterval startTime;
    
    void (^bgCompletionHandler)(UIBackgroundFetchResult);
    //(void (^)(UIBackgroundFetchResult))completionHandler
    
    //(void(^)(Account *))handler;
    //void (^completionHandler)(Account *someParameter);
}

+ (BBBalanceChecker *) sharedBBBalanceChecker;

//
- (void) start;
- (BOOL) isBusy;
- (void) stop;
//
- (void) addItem:(BBMAccount *) account;
- (void) addBgItem:(BBMAccount *) account handler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
