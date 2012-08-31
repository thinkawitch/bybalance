//
//  BBLoadManager.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceChecker.h"

@implementation BBBalanceChecker

SYNTHESIZE_SINGLETON_FOR_CLASS(BBBalanceChecker);

- (void) start
{
    isBusy = YES;
    
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    syncFlag1 = [[NSObject alloc] init];
    syncFlag2 = [[NSObject alloc] init];
    syncFlag3 = [[NSObject alloc] init];
}

- (BOOL) isBusy
{
    return isBusy;
}

- (void) stop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (queue)
    {
        [queue cancelAllOperations];
        [queue release];
        queue = nil;
    }
    
    if (syncFlag1) 
    {
        [syncFlag1 release];
        syncFlag1 = nil;
    }
    if (syncFlag2) 
    {
        [syncFlag2 release];
        syncFlag2 = nil;
    }
    if (syncFlag3) 
    {
        [syncFlag3 release];
        syncFlag3 = nil;
    }
    
    [APP_CONTEXT saveDatabase];
    
    isBusy = NO;
}

@end
