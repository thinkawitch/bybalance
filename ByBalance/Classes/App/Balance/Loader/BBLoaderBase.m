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
@synthesize httpClient;

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
    
    DDLogVerbose(@"%@.start %@ %@", [self class], account.type.name, account.username);
    
    [self markStart];
    [self performSelectorOnMainThread:@selector(notifyAboutUpdatingAccount) withObject:nil waitUntilDone:YES];
    [self startLoader];
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

- (void) startLoader
{
    //base, do nothing
}

- (void) showCookies:(NSString *)url
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
    for (NSHTTPCookie *cookie in cookies)
    {
        DDLogInfo(@"__cookie: %@", cookie);
    }
}

- (void) clearCookies:(NSString *)url
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
    for (NSHTTPCookie *cookie in cookies)
    {
        //DDLogVerbose(@"__cookie: %@", cookie);
        //if ([cookie.name isEqualToString:@"X3"]) continue; //skip velcom
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (void) prepareHttpClient:(NSString *)url
{
    [self clearCookies:url];
    self.httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    [httpClient.requestSerializer setValue:kBrowserUserAgent forHTTPHeaderField:@"User-Agent"];
    httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    httpClient.securityPolicy.allowInvalidCertificates = YES;
}

- (void) extractInfoFromHtml:(NSString *)html
{
    [BASES_MANAGER putUsername:account.username]; //for byfly
    NSInteger type = [account.type.id integerValue];
    BBLoaderInfo * jsInfo = [BASES_MANAGER extractInfoForType:type fromHtml:html];
    
    //might be straight assign to self.loaderInfo
    self.loaderInfo.extracted = jsInfo.extracted;
    self.loaderInfo.incorrectLogin = jsInfo.incorrectLogin;
    if (jsInfo.extracted)
    {
        self.loaderInfo.userBalance = jsInfo.userBalance;
        self.loaderInfo.bonuses = jsInfo.bonuses;
    }
}

- (void) doFinish
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderDone:)])
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.account, self.loaderInfo, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyLoaderInfo, nil]];
        
        [self.delegate balanceLoaderDone:info];
    }
    
    DDLogVerbose(@"%@ %@", self.account.type.name, [self.loaderInfo fullDescription]);
    
    [self markDone];
}

#pragma mark - Utils

- (NSDecimalNumber *) decimalNumberFromString:(id)value
{
    NSString  * buf = [PRIMITIVE_HELPER trimmedString:value];
    buf = [buf stringByReplacingRegexPattern:@"[^0-9.,\\-]" withString:@""];
    return [NSDecimalNumber decimalNumberWithString:buf];
}

- (NSString *) fixUrlEncoding:(NSString *)url
{
    // % values
    NSString * fixed = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // html entities
    NSData * stringData = [fixed dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * options = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSAttributedString * decodedString;
    decodedString = [[NSAttributedString alloc] initWithData:stringData
                                                     options:options
                                          documentAttributes:NULL
                                                       error:NULL];
    fixed = decodedString.string;
    
    return fixed;
}

#pragma mark - Private

- (void) notifyAboutUpdatingAccount
{
    NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, nil]
                                                      forKeys:[NSArray arrayWithObjects:kDictKeyAccount, nil]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnBalanceCheckProgress object:self userInfo:info];
}


@end
