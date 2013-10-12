//
//  BBLoaderMts.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderMts.h"

@interface BBLoaderMts ()

@property (nonatomic,strong) NSString * paramViewState;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end

@implementation BBLoaderMts

@synthesize paramViewState;


#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    /*
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL * url = [NSURL URLWithString:@"https://ihelper.mts.by/SelfCare/"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Host" value:@"ihelper.mts.by"];
    [request addRequestHeader:@"Referer" value:@"https://ihelper.mts.by/SelfCare/"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    self.paramViewState = nil;
    
    return request;
     */
    return nil;
}


#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestStarted", [self class]);
    //NSLog(@"url: %@", request.url);
    
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
    /*
    //NSLog(@"%@.requestFinished", [self class]);
    
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
    
    //NSLog(@"%@", html);
    
    
    if ([step isEqualToString:@"1"])
    {
        [self onStep1:html];
    }
    else if ([step isEqualToString:@"2"])
    {
        [self onStep2:html];
    }
    else
    {
        [self doFinish];
    }
     */
}


#pragma mark - Logic

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderMts.onStep1");
    //NSLog(@"%@", html);
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //try to detect session
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"id=\"__VIEWSTATE\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.paramViewState = buf;
        }
    }
    
    //NSLog(@"paramViewState: %@", self.paramViewState);
    
    if (!self.paramViewState)
    {
        [self doFinish];
        return;
    }
    /*
    NSURL * url = [NSURL URLWithString:@"https://ihelper.mts.by/SelfCare/logon.aspx"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    //[request setRequestMethod:@"POST"];
    //[request setPostFormat:ASIMultipartFormDataPostFormat];
    [request addRequestHeader:@"Host" value:@"ihelper.mts.by"];
    [request addRequestHeader:@"Referer" value:@"https://ihelper.mts.by/SelfCare/"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    [request setPostValue:self.paramViewState forKey:@"__VIEWSTATE"];
    [request setPostValue:account.username forKey:@"ctl00$MainContent$tbPhoneNumber"];
    [request setPostValue:account.password forKey:@"ctl00$MainContent$tbPassword"];
    [request setPostValue:@"Войти" forKey:@"ctl00$MainContent$btnEnter"];
    
    //start request
    [request startAsynchronous];
     */
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderMts.onStep2");
    //NSLog(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //incorrect login/pass
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<div class=\"logon-result-block\">(.+)</div>" caseInsensitive:YES treatAsOneLine:YES];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.incorrectLogin = YES;
        }
    }
    
    if (self.loaderInfo.incorrectLogin)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<h3>(.+)</h3>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userTitle = buf;
        }
    }
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план: <strong>(.+)</strong>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userPlan = buf;
        }
    }
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<span id=\"customer-info-balance\"><strong>(.+)</strong>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    
    self.loaderInfo.extracted = [self.loaderInfo.userTitle length] > 0 && [self.loaderInfo.userPlan length] > 0 && [self.loaderInfo.userBalance length] > 0;
}

@end
