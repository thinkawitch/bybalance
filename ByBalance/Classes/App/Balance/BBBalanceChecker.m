//
//  BBLoadManager.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceChecker.h"


@interface BBBalanceChecker ()
//
@end


@implementation BBBalanceChecker

SYNTHESIZE_SINGLETON_FOR_CLASS(BBBalanceChecker, sharedBBBalanceChecker);

- (void) start
{
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    syncFlag1 = [[NSObject alloc] init];
    syncFlag2 = [[NSObject alloc] init];
}

- (BOOL) isBusy
{
    return queue.operationCount > 0;
}

- (void) stop
{
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
    NSLog(@"BBBalanceChecker.addItem");
    NSLog(@"adding: %@", account.username);
    
    //new way
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
    }
    
    if (!loader)
    {
        NSLog(@"loader not created");
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


#pragma mark - BBLoaderDelegate

- (void) balanceLoaderDone:(NSDictionary *)info
{
    @synchronized (syncFlag1)
	{
        NSLog(@"balanceLoaderDone");
        
        BBMAccount * account = [info objectForKey:kDictKeyAccount];
        BBLoaderInfo * loaderInfo = [info objectForKey:kDictKeyLoaderInfo];
        
        if (!account || !loaderInfo) return;
        
        //save history
        BBMBalanceHistory * bh = [BBMBalanceHistory createEntity];
        bh.date = [NSDate date];
        bh.balance = [NSDecimalNumber decimalNumberWithString: loaderInfo.userBalance];
        bh.extracted = [NSNumber numberWithBool:loaderInfo.extracted];
        bh.incorrectLogin = [NSNumber numberWithBool:loaderInfo.incorrectLogin];
        bh.account = account;
        
        [APP_CONTEXT saveDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceChecked object:self userInfo:info];
        
        if (queue.operationCount <= 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckStop object:self userInfo:nil];
        }
    }
}


#pragma mark - Private


@end
