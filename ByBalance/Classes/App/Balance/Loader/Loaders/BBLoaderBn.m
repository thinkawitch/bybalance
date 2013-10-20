//
//  BBLoaderBn.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderBn.h"

@interface BBLoaderBn ()
@end


@implementation BBLoaderBn

#pragma mark - Logic

- (void) startLoader
{
    [self clearCookies:@"http://ui.bn.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://ui.bn.by/"]];
    [self setDefaultsForHttpClient];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.account.username, @"login",
                            self.account.password, @"passwd",
                            nil];
    
    [self.httpClient postPath:@"/index.php?mode=login&locale=ru" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self extractInfoFromHtml:operation.responseString];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        //NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [self doFinish];
    }];
    
}

- (ASIFormDataRequest *) prepareRequest
{
    /*
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"http://ui.bn.by/index.php?mode=login&locale=ru";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request addRequestHeader:@"Referer" value:loginUrl];
    [request setPostValue:account.username forKey:@"login"];
    [request setPostValue:account.password forKey:@"passwd"];
    
    return request;
     */
    
    return nil;
}

#pragma mark - Logic

- (void) extractInfoFromHtml:(NSString *)html
{
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //incorrect login/pass
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<div class='alarma'>(.+)</div>" caseInsensitive:YES treatAsOneLine:YES];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.incorrectLogin = YES;
        }
    }
    //NSLog(@"incorrectLogin: %d", loaderInfo.incorrectLogin);
    
    if (self.loaderInfo.incorrectLogin)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    //NSLog(@"%@", html);
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td class='title'>Ф.И.О.:</td><td>([^<]+)</td></tr>" caseInsensitive:YES treatAsOneLine:NO];
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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td class='title'>Тариф:</td><td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userPlan = buf;
        }
    }
    //NSLog(@"userPlan: %@", loaderInfo.userPlan);
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий баланс:</td><td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userTitle length] > 0 && [self.loaderInfo.userPlan length] > 0 && [self.loaderInfo.userBalance length] > 0;
}

@end