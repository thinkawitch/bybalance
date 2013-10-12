//
//  BBLoaderVelcom.m
//  ByBalance
//
//  Created by Admin on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderVelcom.h"

@interface BBLoaderVelcom ()

@property (nonatomic,strong) NSString * sessionId;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

@end


@implementation BBLoaderVelcom

@synthesize sessionId;


#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    /*
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
    */
    
    return nil;
}

#pragma mark - ASIHTTPRequestDelegate

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
        [self doFinish];
    }
     */
}

#pragma mark - Logic

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderVelcom.onStep1");
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
    
    //NSLog(@"sessionId: %@", self.sessionId);
    
    if (!self.sessionId)
    {
        [self doFinish];
        return;
    }
    /*
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
    [request setPostValue:@"5" forKey:@"user_input_8"];
    
    [request setPostValue:s1 forKey:@"user_input_1"];
    [request setPostValue:s2 forKey:@"user_input_2"];
    [request setPostValue:account.password forKey:@"user_input_3"];    
    [request setPostValue:@"2" forKey:@"user_input_9"];
    [request setPostValue:@"0" forKey:@"user_input_10"];
    
    //start request
    [request startAsynchronous];
     */
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderVelcom.onStep2");
    //NSLog(@"%@", html);
    
    NSString * menuMarker = @"";
    NSString * menuMarker1 = @"_root/USER_INFO";
    NSString * menuMarker2 = @"_root/MENU0";
    
    BOOL loggedIn = false;
    //check if we logged in
    if ([html rangeOfString:menuMarker1].location != NSNotFound)
    {
        menuMarker = menuMarker1;
        loggedIn = YES;
    }
    else if ([html rangeOfString:menuMarker2].location != NSNotFound)
    {
        menuMarker = menuMarker2;
        loggedIn = YES;
    }

    if (!loggedIn)
    {
        //maybe login problem
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    /*
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
    [request setPostValue:menuMarker forKey:@"user_input_0"];
    [request setPostValue:@"" forKey:@"last_id"];
    
    //start request
    [request startAsynchronous];
     */
}


- (void) onStep3:(NSString *)html
{
    //NSLog(@"BBLoaderVelcom.onStep3");
    //NSLog(@"%@", html);
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    NSString * buf = nil;
    NSArray * arr = nil;
    
    NSString * menuMarker = @"";
    NSString * menuMarker1 = @"_root/USER_INFO";
    NSString * menuMarker2 = @"_root/MENU0";
    
    BOOL loggedIn = false;
    //check if we logged in
    if ([html rangeOfString:menuMarker1].location != NSNotFound)
    {
        menuMarker = menuMarker1;
        loggedIn = YES;
    }
    else if ([html rangeOfString:menuMarker2].location != NSNotFound)
    {
        menuMarker = menuMarker2;
        loggedIn = YES;
    }
    
    if (!loggedIn)
    {
        //incorrect login/pass
        self.loaderInfo.incorrectLogin = ([html rangeOfString:@"INFO_Error_caption"].location != NSNotFound);
        //NSLog(@"incorrectLogin: %d", incorrectLogin);
        
        if (self.loaderInfo.incorrectLogin)
        {
            self.loaderInfo.extracted = NO;
            return;
        }
    }
    
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"ФИО:</td><td class=\"INFO\">([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userTitle = buf;
        }
    }
    //NSLog(@"userTitle: %@", loaderInfo.userTitle);
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:\\s*</td><td class=\"INFO\"[^>]*>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userPlan = buf;
        }
    }
    //NSLog(@"userPlan: %@", loaderInfo.userPlan);
    
    //balance 1
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий баланс:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    
    if (!self.loaderInfo.userBalance || [self.loaderInfo.userBalance length] < 1)
    {
        //balance 2
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Баланс:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            buf = [arr objectAtIndex:0];
            if (nil != buf && [buf length] > 0)
            {
                self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        }
    }
    
    if (!self.loaderInfo.userBalance || [self.loaderInfo.userBalance length] < 1)
    {
        //balance 3
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Начисления\\s*абонента\\*:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            buf = [arr objectAtIndex:0];
            if (nil != buf && [buf length] > 0)
            {
                self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userPlan length] > 0 && [self.loaderInfo.userBalance length] > 0;
}

@end
