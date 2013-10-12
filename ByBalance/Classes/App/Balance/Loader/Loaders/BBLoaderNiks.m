//
//  BBLoaderNiks.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderNiks.h"

@implementation BBLoaderNiks

#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    /*
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"https://user.niks.by/Login.aspx";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setPostValue:@"dDwtOTM5ODc5MjcyOztsPExvZ2luSW1nQnRuOz4+LWAmSvmShzbE7AkSAWCVT7wVAJo=" forKey:@"__VIEWSTATE"];
    [request setPostValue:account.username forKey:@"LoginTxt"];
    [request setPostValue:account.password forKey:@"PasswordTxt"];
    [request setPostValue:@"37" forKey:@"LoginImgBtn.x"];
    [request setPostValue:@"12" forKey:@"LoginImgBtn.y"];

    return request;
     */
    
    return nil;
}

#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    /*
    //NSLog(@"%@.requestFinished", [self class]);
    
    [self extractInfoFromHtml:request.responseString];
    [self doFinish];
     */
}

#pragma mark - Logic

- (void) extractInfoFromHtml:(NSString *)html
{
    //NSLog(@"%@", html);
    
    if (!html)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    self.loaderInfo.incorrectLogin = ([html rangeOfString:@"id=\"MessageLabel\""].location != NSNotFound);
    //NSLog(@"incorrectLogin: %d", incorrectLogin);
    if (self.loaderInfo.incorrectLogin)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Имя:</td>\\s+<td class=\"bgTableGray2\" width=\"50%\" align=\"left\">([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:</td>\\s*<td class=\"bgTableGray2\" width=\"50%\" align=\"left\">\\s*<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\\s*<tr>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userPlan = buf;
        }
    }
    //NSLog(@"userPlan: %@", loaderInfo.userPlan);
    
    //test balance value
    //html = [html stringByReplacingOccurrencesOfString:@"<b>0</b>" withString:@"<b>10 942</b>"];
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Баланс:</td>\\s*<td class=\"bgTableWhite2\" width=\"50%\" align=\"left\">\\s*<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\\s*<tr>\\s*<td nowrap><font color=red><b>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userBalance length] > 0;
}

@end
