//
//  BBLoadManager.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceChecker.h"
#import "ASIFormDataRequest.h"


@interface BBBalanceChecker ()
- (ASIFormDataRequest *) requestWithURL:(NSURL *)anUrl;
- (ASIFormDataRequest *) requestWithItem:(BBMAccount *)account;
@end


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
    //return isBusy;
    return queue.operationCount > 0;
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

- (void) addItem:(BBMAccount *) account
{
    NSLog(@"BBBalanceChecker.addItem");
    NSLog(@"adding: %@", account.username);
    
    ASIFormDataRequest * request = [self requestWithItem:account];
    if (!request)
    {
        NSLog(@"request not created");
        return;
    }
    
    //notify about start
    if (queue.operationCount < 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckStart object:self userInfo:nil];
    }
    
    [queue addOperation:request];
}


#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"BBBalanceChecker.requestStarted");
    NSLog(@"url: %@", request.url);
    
    @synchronized (syncFlag1)
	{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckProgress object:self userInfo:request.userInfo];
    }
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"BBBalanceChecker.requestFinished");
    
    @synchronized (syncFlag2)
	{
        BBMAccount * account = [[request userInfo] objectForKey:kDictKeyAccount];
        BBBaseItem * baseItem = [[request userInfo] objectForKey:kDictKeyBaseItem];
        
        if (!account || !baseItem) return;
        
        //find data
        [baseItem extractFromHtml:request.responseString];
        
        //save history
        BBMBalanceHistory * bh = [BBMBalanceHistory createEntity];
        bh.date = [NSDate date];
        bh.balance = [NSDecimalNumber decimalNumberWithString: baseItem.userBalance];
        bh.isExtracted = [NSNumber numberWithBool:baseItem.isExtracted];
        bh.isBanned = [NSNumber numberWithBool:baseItem.isBanned];
        bh.account = account;
        
        [APP_CONTEXT saveDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceChecked object:self userInfo:request.userInfo];
        
        if (queue.operationCount < 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckStop object:self userInfo:nil];
        }
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"BBBalanceChecker.requestFailed");
    NSLog(@"%@", [request error]);
    
    @synchronized (syncFlag3)
	{
        BBMAccount * account = [[request userInfo] objectForKey:kDictKeyAccount];
        BBBaseItem * baseItem = [[request userInfo] objectForKey:kDictKeyBaseItem];
        
        if (!account || !baseItem) return;
        
        //save history
        BBMBalanceHistory * bh = [BBMBalanceHistory createEntity];
        bh.date = [NSDate date];
        bh.balance = [NSDecimalNumber decimalNumberWithString: @"0.0"];
        bh.isExtracted = [NSNumber numberWithBool:NO];
        bh.isBanned = [NSNumber numberWithBool:NO];
        bh.account = account;
        
        [APP_CONTEXT saveDatabase];
        
        if (queue.operationCount < 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckStop object:self userInfo:nil];
        }
    }
}

#pragma mark - Private

- (ASIFormDataRequest *) requestWithURL:(NSURL *)anUrl
{
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL: anUrl];
    
    request.timeOutSeconds = 30;
    request.userAgentString = @"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:14.0) Gecko/20100101 Firefox/14.0.1";
    request.delegate = self;
    
    //add some parameters, common for all requests
    
    
    return request;
}

- (ASIFormDataRequest *) requestWithItem:(BBMAccount *)account
{
    BBBaseItem * baseItem = account.basicItem;
    if (!baseItem) return nil;
    
    NSURL * url = [NSURL URLWithString:baseItem.loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    //remember request data
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, baseItem, nil] 
                                                   forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyBaseItem, nil]];
    
    NSInteger type = [account.type.id intValue];
    
    if (type == kAccountMTS)
    {
        [request addRequestHeader:@"Referer" value:baseItem.loginUrl];
        [request setPostValue:@"/wEPDwUKMTU5Mzk3MTA0NA9kFgJmD2QWAgICDxYCHgVjbGFzcwUFbG9naW4WAgICD2QWBgIBDw8WAh4JTWF4TGVuZ3RoAglkZAIDDw8WAh4DS0VZBSJjdGwwMF9NYWluQ29udGVudF9jYXB0Y2hhMzA2MjI5NzAwZGQCBQ8PFgYeBFRleHRlHghDc3NDbGFzcwUGc3VibWl0HgRfIVNCAgJkZGRq1lFdf8Isy5ch/s7SUIwpqQoOoA==" forKey:@"__VIEWSTATE"];
        [request setPostValue:account.username forKey:@"ctl00$MainContent$tbPhoneNumber"];
        [request setPostValue:account.password forKey:@"ctl00$MainContent$tbPassword"];
        [request setPostValue:@"Войти" forKey:@"ctl00$MainContent$btnEnter"];
    }
    
    return request;
}

@end
