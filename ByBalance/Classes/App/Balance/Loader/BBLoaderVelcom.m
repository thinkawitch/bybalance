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
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

- (void) doFail;
- (void) doSuccess:(NSString *)html;

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
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL * url = [NSURL URLWithString:@"https://internet.velcom.by/"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Host" value:@"internet.velcom.by"];
    [request addRequestHeader:@"Referer" value:@"http://www.velcom.by/"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    self.sessionId = nil;
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestStarted", [self class]);
    NSLog(@"url: %@", request.url);
    
    /*
    for (NSString * name in request.requestHeaders)
    {
        NSLog(@"[header] %@: %@", name, [request.requestHeaders objectForKey:name]);
    }
    
    for (NSString * name in request.requestCookies)
    {
        NSLog(@"[cookie] %@", name);
    }
    */
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFinished", [self class]);
    
    NSString * step = [request.userInfo objectForKey:@"step"];
    
    //NSLog(@"responseEncoding %d", request.responseEncoding);
    
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
    else
    {
        [self doFail];
    }
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
    //NSLog(@"%@", html);
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //try to detect session
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"name=\"sid3\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.sessionId = buf;
        }
    }
    
    NSLog(@"sessionId: %@", self.sessionId);
    
    if (!self.sessionId)
    {
        [self doFail];
        return;
    }
    
    NSURL * url = [NSURL URLWithString:@"https://internet.velcom.by/work.html"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request addRequestHeader:@"Host" value:@"internet.velcom.by"];
    [request addRequestHeader:@"Referer" value:@"https://internet.velcom.by/"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    NSNumber * ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSString * s1 = [account.username substringToIndex:2];
    NSString * s2 = [account.username substringFromIndex:2];
    
    [request setPostValue:self.sessionId forKey:@"sid3"];
    [request setPostValue:ts forKey:@"user_input_timestamp"];
    [request setPostValue:@"_next" forKey:@"user_input_0"];
    [request setPostValue:@"" forKey:@"last_id"];
    [request setPostValue:@"1" forKey:@"user_input_10"];
    [request setPostValue:s1 forKey:@"user_input_1"];
    [request setPostValue:s2 forKey:@"user_input_2"];
    [request setPostValue:account.password forKey:@"user_input_3"];
    [request setPostValue:@"0" forKey:@"user_input_9"];
    [request setPostValue:@"1" forKey:@"user_input_8"];
    
    //start request
    [request startAsynchronous];
}

- (void) onStep2:(NSString *)html
{
    NSLog(@"BBLoaderVelcom.onStep2");
    //NSLog(@"%@", html);
    
    //check if we logged in
    BOOL loggedIn = ([html rangeOfString:@"_root/USER_INFO"].location != NSNotFound);
    
    if (!loggedIn)
    {
        //maybe login problem
        //[self doFail];
        [self doSuccess:html];
        return;
    }
    
    NSURL * url = [NSURL URLWithString:@"https://internet.velcom.by/work.html"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request addRequestHeader:@"Host" value:@"internet.velcom.by"];
    [request addRequestHeader:@"Referer" value:@"https://internet.velcom.by/work.html"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"3", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    NSNumber * ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    [request setPostValue:self.sessionId forKey:@"sid3"];
    [request setPostValue:ts forKey:@"user_input_timestamp"];
    [request setPostValue:@"_root/USER_INFO" forKey:@"user_input_0"];
    [request setPostValue:@"" forKey:@"last_id"];
    
    //start request
    [request startAsynchronous];

}


- (void) onStep3:(NSString *)html
{
    NSLog(@"BBLoaderVelcom.onStep3");
    //NSLog(@"%@", html);
    
    [self doSuccess:html];
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

- (void) doSuccess:(NSString *)html
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderSuccess:)] )
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, html, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyHtml, nil]];
        
        [self.delegate balanceLoaderSuccess:info];
    }
    
    [self markDone];
}

@end
