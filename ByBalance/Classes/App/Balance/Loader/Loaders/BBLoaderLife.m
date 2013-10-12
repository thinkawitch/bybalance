//
//  BBLoaderLife.m
//  ByBalance
//
//  Created by Admin on 17.11.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderLife.h"

@implementation BBLoaderLife

#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    /*
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"https://issa.life.com.by/";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    NSString * s1 = [account.username substringToIndex:2];
    NSString * s2 = [account.username substringFromIndex:2];
    
    [request addRequestHeader:@"Referer" value:loginUrl];
    [request setPostValue:s1 forKey:@"Code"];
    [request setPostValue:account.password forKey:@"Password"];
    [request setPostValue:s2 forKey:@"Phone"];
    
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
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //NSLog(@"%@", html);
    
    BOOL loggedIn = ([html rangeOfString:@"/Account.aspx/Logoff"].location != NSNotFound);
    if (!loggedIn)
    {
        //incorrect login/pass
        self.loaderInfo.incorrectLogin = ([html rangeOfString:@"errorMessage"].location != NSNotFound);
        //NSLog(@"incorrectLogin: %d", incorrectLogin);
        
        if (self.loaderInfo.incorrectLogin)
        {
            self.loaderInfo.extracted = NO;
            return;
        }
    }
    
    
    //userTitle
    /*
     <div class="divBold">Фамилия:</div>
     <div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Фамилия:\\s*</div>\\s*<div>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userTitle = [buf stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    //NSLog(@"userTitle: %@", loaderInfo.userTitle);
    
    //userPlan
    /*
     <div class="divBold">
     Тарифный план:
     </div>
     <div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:\\s*</div>\\s*<div>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userPlan = [buf stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    //NSLog(@"userPlan: %@", loaderInfo.userPlan);
    
    //balance
    /*
     <div class="divBold">
     Текущий основной баланс: *
     </div>
     <div>
     7 500,00р.
     </div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий основной баланс: \\*\\s*</div>\\s*<div>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            //self.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            self.loaderInfo.userBalance = [buf stringByReplacingRegexPattern:@"[^0-9.,]" withString:@""];
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userPlan length] > 0 && [self.loaderInfo.userBalance length] > 0;
}

@end
