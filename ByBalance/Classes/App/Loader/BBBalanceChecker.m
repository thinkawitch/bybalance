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
    
    isBusy = NO;
}

@end
