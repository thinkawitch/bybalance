//
//  BBLoadManager.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceChecker.h"


@interface BBBalanceChecker ()

- (BBLoaderBase *)loaderForAccount:(BBMAccount *) account;

- (void) startBgFetchTimer;
- (void) stopBgFetchTimer;
- (void) onBgFetchTimerTick:(NSTimer *)timer;
- (void) onBgUpdateEnd:(BOOL)updated;

@end


@implementation BBBalanceChecker

SYNTHESIZE_SINGLETON_FOR_CLASS(BBBalanceChecker, sharedBBBalanceChecker);

- (void) start
{
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    syncFlag1 = [[NSObject alloc] init];
    syncFlag2 = [[NSObject alloc] init];
    
    bgTimeLimit = 28;
    bgUpdate = NO;
}

- (BOOL) isBusy
{
    return queue.operationCount > 0;
}

- (void) stop
{
    [self stopBgFetchTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (queue)
    {
        [queue cancelAllOperations];
        queue = nil;
    }
    
    if (syncFlag1) syncFlag1 = nil;
    if (syncFlag2) syncFlag2 = nil;
}

- (void) addItem:(BBMAccount *) account
{
    DDLogVerbose(@"BBBalanceChecker.addItem");
    DDLogVerbose(@"adding: %@", account.username);
    
    //new way
    BBLoaderBase * loader = [self loaderForAccount:account];
    
    if (!loader)
    {
        DDLogError(@"loader not created");
        return;
    }
    
    loader.account = account;
    loader.delegate = self;
    
    //notify about start
    if (queue.operationCount < 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckStart object:self userInfo:nil];
    }
    
    [queue addOperation:loader];
}

- (void) addBgItem:(BBMAccount *)account handler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DDLogVerbose(@"BBBalanceChecker.addBgItem");
    DDLogVerbose(@"adding: %@", account.username);
    
    BBLoaderBase * loader = [self loaderForAccount:account];
    
    if (!loader)
    {
        DDLogError(@"loader not created");
        return;
    }
    
    bgCompletionHandler = [completionHandler copy];
    
    loader.account = account;
    loader.delegate = self;
    
    //notify about start
    if (queue.operationCount < 1)
    {
        bgUpdate = YES;
        [self startBgFetchTimer];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckStart object:self userInfo:nil];
    }
    
    [queue addOperation:loader];
}

#pragma mark - BBLoaderDelegate

- (void) balanceLoaderDone:(NSDictionary *)info
{
    @synchronized (syncFlag1)
	{
        DDLogVerbose(@"balanceLoaderDone");
        
        BBMAccount * account = [info objectForKey:kDictKeyAccount];
        BBLoaderInfo * loaderInfo = [info objectForKey:kDictKeyLoaderInfo];
        
        if (!account || !loaderInfo) return;
        
        //save history
        BBMBalanceHistory * bh = [BBMBalanceHistory createEntity];
        bh.date = [NSDate date];
        bh.account = account;
        bh.extracted = [NSNumber numberWithBool:loaderInfo.extracted];
        bh.incorrectLogin = [NSNumber numberWithBool:loaderInfo.incorrectLogin];
        bh.balance = loaderInfo.userBalance;
        bh.packages = loaderInfo.userPackages;
        bh.megabytes = loaderInfo.userMegabytes;
        bh.days = loaderInfo.userDays;
        bh.credit = loaderInfo.userCredit;
        bh.minutes = loaderInfo.userMinutes;
        bh.sms = loaderInfo.userSms;
        
        [APP_CONTEXT saveDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceChecked object:self userInfo:info];
        
        if (queue.operationCount <= 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckStop object:self userInfo:nil];
            if (bgUpdate) [self onBgUpdateEnd:YES];
        }
    }
}


#pragma mark - Private

- (BBLoaderBase *)loaderForAccount:(BBMAccount *) account
{
    NSInteger type = [account.type.id integerValue];
    
    BBLoaderBase * loader = nil;
    
    switch (type)
    {
        case kAccountMts:
            loader = [BBLoaderMts new];
            break;
            
        case kAccountBn:
            loader = [BBLoaderBn new];
            break;
            
        case kAccountVelcom:
            loader = [BBLoaderVelcom new];
            break;
            
        case kAccountLife:
            loader = [BBLoaderLife new];
            break;
            
        case kAccountTcm:
            loader = [BBLoaderTcm new];
            break;
            
        case kAccountNiks:
            loader = [BBLoaderNiks new];
            break;
            
        case kAccountDamavik:
        case kAccountSolo:
        case kAccountTeleset:
            loader = [BBLoaderDamavik new];
            [(BBLoaderDamavik*)loader actAsDamavik];
            break;
            
        case kAccountAtlantTelecom:
            loader = [BBLoaderDamavik new];
            [(BBLoaderDamavik*)loader actAsAtlantTelecom];
            break;
            
        case kAccountByFly:
            loader = [BBLoaderByFly new];
            break;
            
        case kAccountNetBerry:
            loader = [BBLoaderNetBerry new];
            break;
            
        case kAccountCosmosTv:
            loader = [BBLoaderCosmosTV new];
            break;
            
        case kAccountInfolan:
            loader = [BBLoaderInfolan new];
            break;
            
        case kAccountUnetBy:
            loader = [BBLoaderUnetBy new];
            break;
            
        case kAccountDiallog:
            loader = [BBLoaderDiallog new];
            break;
            
        case kAccountAnitex:
            loader = [BBLoaderAnitex new];
            break;
    }
    
    return loader;
}

- (void) startBgFetchTimer
{
    if (timer) [self stopBgFetchTimer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.05f
                                             target: self
                                           selector:@selector(onBgFetchTimerTick:)
                                           userInfo: nil
                                            repeats:YES];
    startTime = CACurrentMediaTime();
}

- (void) stopBgFetchTimer
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

- (void) onBgFetchTimerTick:(NSTimer *)timer
{
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    
    if (elapsedTime < bgTimeLimit) return;
    
    DDLogVerbose(@"time passed: %f, stopping current check", elapsedTime);
    
    [self onBgUpdateEnd:NO];
}

- (void) onBgUpdateEnd:(BOOL)updated
{
    DDLogVerbose(@"BBBalanceChecker.bgUpdated: %d", updated);
    
    [self stop];
    [self start];
    
    bgUpdate = NO;
    
    if (updated)
    {
        if (bgCompletionHandler)
        {
            DDLogVerbose(@"normal update");
            bgCompletionHandler(UIBackgroundFetchResultNewData);
        }
    }
    else
    {
        if (bgCompletionHandler)
        {
            DDLogVerbose(@"no enough time to complete");
            bgCompletionHandler(UIBackgroundFetchResultNoData);
        }
    }
    
    bgCompletionHandler = nil;
}

@end
