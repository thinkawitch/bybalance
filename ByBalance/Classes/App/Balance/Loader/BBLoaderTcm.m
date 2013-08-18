//
//  BBLoaderTcm.m
//  ByBalance
//
//  Created by Admin on 16.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderTcm.h"

@implementation BBLoaderTcm

#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"https://tcm.by/info.php";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setPostValue:account.username forKey:@"login"];
    [request setPostValue:account.password forKey:@"password"];
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestFinished", [self class]);
    
    [self extractInfoFromHtml:request.responseString];
    [self doFinish];
}

#pragma mark - Logic

- (void) extractInfoFromHtml:(NSString *)html
{
    //NSLog(@"%@", html);
    
    if (!html)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    if ([html isEqualToString:@"ERROR"] || [html isEqualToString:@"FORBIDDEN"])
    {
        loaderInfo.incorrectLogin = YES;
        return;
    }
    
    /*
     5081;2703034;226203;0;1;
     
     Где:
     5081 - номер лицевого счета
     2703034 - логин
     226203 - баланс, руб.
     0 - кредит, руб.
     1 - статус интернета (0 - ОТКЛ, 1 - ВКЛ)
     */
    
    NSArray *arr = [html componentsSeparatedByString:@";"];
    if (!arr || [arr count] <3)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSString * bal = [arr objectAtIndex:2];
    if (![APP_CONTEXT stringIsNumeric:bal])
    {
        loaderInfo.extracted = NO;
        return;
    }
    loaderInfo.userBalance = bal;
    
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    loaderInfo.extracted = YES;
}

@end
