//
//  BBLoaderVelcom.m
//  ByBalance
//
//  Created by Admin on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderVelcom.h"

@interface BBLoaderVelcom ()

@property (strong, readwrite) NSString * sessionId;

- (void) onStep1:(NSString *)html;
//- (void) step2start;
- (void) onStep2:(NSString *)html;
//- (void) step3start;
- (void) onStep3:(NSString *)html;

- (void) doFail;
- (void) doSuccess;

@end


@implementation BBLoaderVelcom

@synthesize sessionId;

#pragma mark - ObjectLife

- (void) dealloc
{
    self.sessionId = nil;
    
    [super dealloc];
}

- (ASIFormDataRequest *) prepareRequest
{
    NSURL * url = [NSURL URLWithString:@"https://internet.velcom.by/"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    //request.useCookiePersistence = NO;
//    request.useSessionPersistence = NO;
    
    //[request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    //[request addRequestHeader:@"Accept-Language" value:@"en-us,en;q=0.5"];
    //[request addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    //[request addRequestHeader:@"Cache-Control" value:@"no-store, no-cache"];
    //[request addRequestHeader:@"Connection" value:@"keep-alive"];
    //[request addRequestHeader:@"Cookie" value:@"__utma=188814252.644509678.1343864594.1348941338.1348944137.6; __utmz=188814252.1343864594.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utmc=188814252; __utmb=188814252.1.10.1348944137"];
    //[request addRequestHeader:@"Host" value:@"internet.velcom.by"];
    //[request addRequestHeader:@"Referer" value:@"http://www.velcom.by/"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];

    request.delegate = self;
    
    
    self.sessionId = @"";
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestStarted", [self class]);
    NSLog(@"url: %@", request.url);
   // NSLog(@"%@", request.headers)
    
    for (NSString * name in request.requestHeaders)
    {
        NSLog(@"%@: %@", name, [request.requestHeaders objectForKey:name]);
    }
    
    for (NSString * name in request.requestCookies)
    {
        NSLog(@"%@", name);
    }
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFinished", [self class]);
    
    //[self doFail];
    //return;
    
    NSString * step = [request.userInfo objectForKey:@"step"];
    
    NSLog(@"responseEncoding %d", request.responseEncoding);
    
    NSString * html = nil;
    if (request.responseEncoding == NSISOLatin1StringEncoding)
    {
        html = [[[NSString alloc] initWithData:request.responseData encoding:NSWindowsCP1251StringEncoding] autorelease];
    }
    else
    {
        html = request.responseString;
    }
    
    
    if ([step isEqualToString:@"1"])
    {
        [self onStep1:html];
    }
    else if ([step isEqualToString:@"2"])
    {
        [self onStep2:html];
    }
    else if ([step isEqualToString:@"3"])
    {
        [self onStep3:html];
    }
    
    
    [self doFail];
    
    /*
    
    if ([self.delegate respondsToSelector:@selector(balanceLoaderSuccess:)] )
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, request.responseString, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyHtml, nil]];
        
        [self.delegate balanceLoaderSuccess:info];
    }
    
    [self markDone];
    */
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFailed" , [self class]);
    NSLog(@"%@", [request error]);
    
    [self doFail];
}

#pragma mark - Logic

- (void) onStep1:(NSString *)html
{
    NSLog(@"BBLoaderVelcom.onStep1");
    NSLog(@"%@", html);

}

- (void) onStep2:(NSString *)html
{
    
}


- (void) onStep3:(NSString *)html
{
    
}

- (void) doFail
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderFail:)] )
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, nil]];
        
        [self.delegate balanceLoaderFail:info];
    }
    
    [self markDone];
}

- (void) doSuccess
{
    
}

@end
