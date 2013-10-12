//
//  BBLoaderBase.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderBase.h"

@interface BBLoaderBase()
- (void) notifyAboutUpdatingAccount;
@end;


@implementation BBLoaderBase

@synthesize account;
@synthesize delegate;
@synthesize loaderInfo;

#pragma mark - ObjectLife

- (id) init
{
	self = [super init];
	if (self)
	{
        self.loaderInfo = [BBLoaderInfo new];
	}
	
	return self;
}


#pragma mark - NSOperation

- (void) start
{
    // Ensure this operation is not being restarted and that it has not been cancelled
    if (loaderFinished || [self isCancelled])
    {
        [self markDone];
        return;
    }
    
    NSLog(@"%@.start %@ %@", [self class], account.type.name, account.username);
    
    /*
    if (self.isAFNetworking)
    {
        [self markStart];
        
        //notify about progress
        [self performSelectorOnMainThread:@selector(notifyAboutUpdatingAccount) withObject:nil waitUntilDone:YES];
        
        //start request
        [self startAFNetworking];
    }
    else
    {
        ASIFormDataRequest * request = [self prepareRequest];
        if (!request)
        {
            [self markDone];
            return;
        }
        
        [self markStart];
        
        //notify about progress
        [self performSelectorOnMainThread:@selector(notifyAboutUpdatingAccount) withObject:nil waitUntilDone:YES];
        
        //start request
        [request startAsynchronous];
    }
    */
    
}

- (BOOL) isConcurrent
{
    return YES;
}

- (BOOL) isExecuting
{
    return loaderExecuting;
}

- (BOOL) isFinished
{
    return loaderFinished;
}

- (void) markStart
{
    [self willChangeValueForKey:@"isExecuting"];
    loaderExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void) markStop
{
    [self willChangeValueForKey:@"isExecuting"];
    loaderExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void) markDone
{
    [self willChangeValueForKey:@"isExecuting"];
    loaderExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    loaderFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Logic

- (ASIFormDataRequest *) requestWithURL:(NSURL *)url
{
    /*
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL: url];
    
    request.timeOutSeconds = 12.f;
    request.userAgentString = @"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:22.0) Gecko/20100101 Firefox/22.0";
    request.delegate = self;
    
    //add some parameters, common for all requests
    
    return request;
    */
    
    return nil;
}

- (ASIFormDataRequest *) prepareRequest
{
    return nil;
}

- (BOOL) isAFNetworking
{
    return NO;
}

- (void) startAFNetworking
{
    //base, do nothing
}

- (void) extractInfoFromHtml:(NSString *)html
{
    //base, do nothing
}

- (void) doFinish
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderDone:)])
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.account, self.loaderInfo, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyLoaderInfo, nil]];
        
        [self.delegate balanceLoaderDone:info];
    }
    
    NSLog(@"%@ %@", self.account.type.name, [self.loaderInfo fullDescription]);
    
    [self markDone];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestStarted", [self class]);
    //NSLog(@"url: %@", request.url);
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestFinished", [self class]);
    //NSLog(@"%@", request.responseString);
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestFailed" , [self class]);
    //NSLog(@"%@", [request error]);
    
    [self doFinish];
}


#pragma mark - Private

- (void) notifyAboutUpdatingAccount
{
    NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, nil]
                                                      forKeys:[NSArray arrayWithObjects:kDictKeyAccount, nil]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckProgress object:self userInfo:info];
}


@end
