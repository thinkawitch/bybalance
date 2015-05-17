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

- (double) timeForCheckPeriodType:(NSInteger)periodType;
- (void) notifyAboutLimits;

@end


@implementation BBBalanceChecker

SYNTHESIZE_SINGLETON_FOR_CLASS(BBBalanceChecker, sharedBBBalanceChecker);

- (void) start
{
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    syncFlag1 = [[NSObject alloc] init];
    syncFlag2 = [[NSObject alloc] init];
    
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

- (void) setBgCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    bgCompletionHandler = [completionHandler copy];
}

- (void) addBgItem:(BBMAccount *)account
{
    DDLogVerbose(@"BBBalanceChecker.addBgItem");
    DDLogVerbose(@"adding: %@", account.username);
    
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
        bh.bonuses = loaderInfo.bonuses;
        
        [APP_CONTEXT saveDatabase];
        
        [self saveAccountsForTodayWidget];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceChecked object:self userInfo:info];
        
        if (queue.operationCount <= 1)
        {
            [GROUP_SETTINGS load];
            if (GROUP_SETTINGS.updateBegin == 1) GROUP_SETTINGS.updateEnd = 1;
            [GROUP_SETTINGS save];
            
            [self notifyAboutLimits];
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
            //dead
            break;
            
        case kAccountAnitex:
            loader = [BBLoaderAnitex new];
            break;
            
        case kAccountAdslBy:
            loader = [BBLoaderAdslBy new];
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
    
    if (elapsedTime < kBgBcTimelimit) return;
    
    DDLogVerbose(@"time passed: %f, stopping current check", elapsedTime);
    
    [self onBgUpdateEnd:NO];
}

- (void) onBgUpdateEnd:(BOOL)updated
{
    DDLogVerbose(@"BBBalanceChecker.bgUpdated: %d", updated);
    
    [self stop];
    [self start];
    
    //bgfetch was in background
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) [APP_CONTEXT stopReachability];
    
    if (bgCompletionHandler)
    {
        if (updated)
        {
            DDLogVerbose(@"bgFetch - normal update end");
            bgCompletionHandler(UIBackgroundFetchResultNewData);
        }
        else
        {
            DDLogVerbose(@"bgFetch - no enough time to complete");
            bgCompletionHandler(UIBackgroundFetchResultNewData);
        }
    }
    
    bgCompletionHandler = nil;
}

- (NSArray *) checkPeriodTypes
{
    //array indexes must match kPeriodicChecks enum
    
    static NSArray * checkTypes;
    
    if (!checkTypes)
    {
        checkTypes = [NSArray arrayWithObjects:@"Вручную", @"При запуске", @"Каждые 2 часа", @"Каждые 4 часа", @"Каждые 8 часов", @"Раз в сутки", nil];
    }
    
    return checkTypes;
}

- (double) timeForCheckPeriodType:(NSInteger)periodType
{
    switch (periodType)
    {
        case kPeriodicCheckManual: return 0;
        case kPeriodicCheckOnStart: return 0;
        case kPeriodicCheck2h: return 60*60*2 - 2*60;  //2 minutes time difference
        case kPeriodicCheck4h: return 60*60*4 - 2*60;
        case kPeriodicCheck8h: return 60*60*8 - 2*60;
        case kPeriodicCheck1d: return 60*60*24 - 2*60;
        default: return 0;
    }
}

- (NSArray *) accountsToCheckInBg
{
    NSDate * date = [NSDate date];
    NSTimeInterval timeNow = [date timeIntervalSinceReferenceDate];
    NSTimeInterval timePassed = 0;
    
    double limit = 0;
    double timeNeverChecked = 60*60*24*365;

    BBMAccount * acc = nil;
    BBMBalanceHistory * bh = nil;
    
    //all accounts that needs to be checked
    NSMutableArray * toCheckAccounts = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (acc in [BBMAccount findAllSortedBy:@"order" ascending:YES])
    {
        bh = [acc lastBalance];
        
        if (!bh) timePassed = timeNeverChecked;
        else timePassed = timeNow - [bh.date timeIntervalSinceReferenceDate];
        
        limit = [self timeForCheckPeriodType:[acc.periodicCheck integerValue]];
        
        if (limit > 0 && timePassed > limit)
        {
            [toCheckAccounts addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:acc, [NSNumber numberWithDouble:timePassed], nil]
                                                                   forKeys:[NSArray arrayWithObjects:@"account", @"timePassed", nil]]];
        }
    }
    
    NSInteger toCheckCount = [toCheckAccounts count];
    if (toCheckCount < 1) return nil;
    
    //sort by timePassed desc
    [toCheckAccounts sortUsingComparator: ^(id lhs, id rhs) {
        NSNumber * n1 = ((NSDictionary*) lhs)[@"timePassed"];
        NSNumber * n2 = ((NSDictionary*) rhs)[@"timePassed"];
        if (n1.doubleValue > n2.doubleValue) return NSOrderedAscending;
        if (n1.doubleValue < n2.doubleValue) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    NSInteger lim = (toCheckCount >= 4) ? 4 : toCheckCount;
    NSMutableArray * limitedList = [[NSMutableArray alloc] initWithCapacity:lim];
    for (int i=0; i<lim; i++)
    {
        NSDictionary * dic = [toCheckAccounts objectAtIndex:i];
        [limitedList addObject:[dic objectForKey:@"account"]];
    }
    
    return limitedList;
}

- (NSArray *) accountsToCheckOnStart
{
    NSDate * date = [NSDate date];
    NSTimeInterval timeNow = [date timeIntervalSinceReferenceDate];
    NSTimeInterval timePassed = 0;
    
    double limit = 0;
    double limitOnStart = 60*30; //30 mins
    double timeNeverChecked = 60*60*24*365;
    NSInteger periodicCheckVal = 0;
    
    BBMAccount * acc = nil;
    BBMBalanceHistory * bh = nil;
    
    //all accounts that needs to be checked
    NSMutableArray * toCheckAccounts = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (acc in [BBMAccount findAllSortedBy:@"order" ascending:YES])
    {
        bh = [acc lastGoodBalance];
        periodicCheckVal = [acc.periodicCheck integerValue];
        
        //skip others
        if (periodicCheckVal == kPeriodicCheckManual) continue;
        
        if (!bh) timePassed = timeNeverChecked;
        else timePassed = timeNow - [bh.date timeIntervalSinceReferenceDate];
        
        if (periodicCheckVal == kPeriodicCheckOnStart) limit = limitOnStart;
        else limit = [self timeForCheckPeriodType:periodicCheckVal] + 3*60;
        
        if (timePassed > limit) [toCheckAccounts addObject:acc];
    }
    
    return toCheckAccounts;
}

- (void) notifyAboutLimits
{
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"balanceLimit > 0"];
    NSArray * arr = [BBMAccount findAllSortedBy:@"order" ascending:YES withPredicate:pred];
    if (!arr || [arr count] < 1) return;
    
    //items checked 1 min ago
    NSDate * date = [[NSDate date] dateByAddingTimeInterval:-60];

    NSMutableArray * list = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray * names = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (BBMAccount * acc in arr)
    {
        BBMBalanceHistory * h = [acc lastGoodBalance];
        if (!h) continue;
        
        if ([h.date compare:date] == NSOrderedDescending && [acc.balanceLimit doubleValue] > [h.balance doubleValue])
        {
            [list addObject:acc];
            [names addObject:acc.nameLabel];
        }
    }
    
    NSInteger count = [list count];
    if (count < 1) return;
    
    NSString * alertBody = nil;
    if (count > 3)
    {
        NSString * w1 = [APP_CONTEXT formatWordAccount:count];
        NSString * w2 = [APP_CONTEXT formatWordCrossed:count];
        alertBody = [NSString stringWithFormat:@"%ld %@ %@ лимит", (long)count, w1, w2];
    }
    else
    {
        NSString * w1 = [names componentsJoinedByString: @", "];
        NSString * w2 = [APP_CONTEXT formatWordCrossed:count];
        alertBody = [NSString stringWithFormat:@"%@ - %@ лимит", w1, w2];
    }
        
    UILocalNotification * localNotif = [[UILocalNotification alloc] init];
    if (localNotif)
    {
        localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval:2];
        localNotif.alertBody = alertBody;
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = count;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}

#pragma mark - Server

- (void) serverAddToken:(NSString *)token
{
    NSString * newToken = token;
    NSString * oldToken = [SETTINGS apnToken];
    AFHTTPRequestOperationManager * httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kApnServerUrl]];
    
    if ([oldToken isEqualToString:newToken] || [oldToken length] < 1)
    {
        //add token
        NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:newToken, @"token", kApnServerEnv, @"env", nil];
        
        [httpClient POST:@"add_token/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            SETTINGS.apnToken = newToken;
            [SETTINGS save];
            [GROUP_SETTINGS load];
            GROUP_SETTINGS.apnToken = newToken;
            [GROUP_SETTINGS save];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            DDLogError(@"%s httpclient_error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }];
    }
    else if ([oldToken length] > 0)
    {
        //update token
        NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                                 oldToken, @"old_token",
                                 newToken, @"new_token",
                                 kApnServerEnv, @"env",
                                 nil];
        
        [httpClient POST:@"update_token/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            SETTINGS.apnToken = newToken;
            [SETTINGS save];
            [GROUP_SETTINGS load];
            GROUP_SETTINGS.apnToken = newToken;
            [GROUP_SETTINGS save];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            DDLogError(@"%s httpclient_error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }];
    }
}

- (void) serverRemoveToken
{
    NSString * token = [SETTINGS apnToken];
    
    if ([token length] < 1) return;
    
    //remove token
    
    AFHTTPRequestOperationManager * httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kApnServerUrl]];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", kApnServerEnv, @"env", nil];
    
    [httpClient POST:@"remove_token/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        SETTINGS.apnToken = @"";
        [SETTINGS save];
        [GROUP_SETTINGS load];
        GROUP_SETTINGS.apnToken = @"";
        [GROUP_SETTINGS save];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%s httpclient_error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }];
}

- (void) saveAccountsForTodayWidget
{
    if (!APP_CONTEXT.isIos8) return;
    
    NSMutableArray * widgetAccounts = [NSMutableArray array];
    
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"inTodayWidget = 1"];
    NSArray * arr = [BBMAccount findAllSortedBy:@"order" ascending:YES withPredicate:pred];
    
    for (BBMAccount * acc in arr)
    {
        BBMBalanceHistory * h = [acc lastBalance];
        
        NSMutableDictionary * record = [NSMutableDictionary dictionaryWithCapacity:3];
        [record setObject:acc.nameLabel forKey:@"name"];
        
        if (h)
        {
            NSString * balance = nil;
            if ([h.extracted boolValue])
            {
                balance = [NSNumberFormatter localizedStringFromNumber:h.balance
                                                           numberStyle:NSNumberFormatterDecimalStyle];
            }
            else
            {
                balance = @"ошибка";
            }
            
            [record setObject:balance forKey:@"balance"];
            [record setObject:[DATE_HELPER dateToMysqlDateTime:h.date] forKey:@"date"];
        }
        else
        {
            [record setObject:@"-" forKey:@"balance"];
            [record setObject:@"-" forKey:@"date"];
        }
        
        [widgetAccounts addObject:record];
    }
    
    [GROUP_SETTINGS load];
    [GROUP_SETTINGS setAccounts:widgetAccounts];
    [GROUP_SETTINGS save];
}

@end
