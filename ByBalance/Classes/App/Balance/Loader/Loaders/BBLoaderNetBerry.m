//
//  BBLoaderNetBerry.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 21.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderNetBerry.h"

@interface BBLoaderNetBerry ()

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end

@implementation BBLoaderNetBerry

#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    /*
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL * url = [NSURL URLWithString:@"https://user.nbr.by/bgbilling/webexecuter"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Host" value:@"user.nbr.by"];
    [request addRequestHeader:@"Referer" value:@"https://user.nbr.by/bgbilling/webexecuter"];
    
    [request setValidatesSecureCertificate:NO];
    
    [request addPostValue:@"0" forKey:@"midAuth"];
    [request addPostValue:account.username forKey:@"user"];
    [request addPostValue:account.password forKey:@"pswd"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
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
    else
    {
        [self doFinish];
    }
     */
}

#pragma mark - Logic

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderNetBerry.onStep1");
    //NSLog(@"%@", html);
    
    //Ошибка при авторизации
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    //ссылка на страницу баланса
    if ([html rangeOfString:@"?action=ShowBalance&mid=contract"].location == NSNotFound)
    {
        [self doFinish];
        return;
    }
    
    //https://user.nbr.by/bgbilling/webexecuter?action=ShowBalance&mid=contract
    /*
    NSURL * url = [NSURL URLWithString:@"https://user.nbr.by/bgbilling/webexecuter?action=ShowBalance&mid=contract"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    
    [request setValidatesSecureCertificate:NO];
    
    [request addRequestHeader:@"Host" value:@"user.nbr.by"];
    [request addRequestHeader:@"Referer" value:@"https://user.nbr.by/bgbilling/webexecuter"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    [request startAsynchronous];
     */
    
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderNetBerry.onStep2");
    //NSLog(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    /*
    if (!html)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        loaderInfo.incorrectLogin = YES;
        loaderInfo.extracted = NO;
        return;
    }
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //balance
    // <th>Исходящий остаток на конец месяца</th><td>22 539.06</td>
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Исходящий остаток на конец месяца</th>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            buf = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:buf];
            loaderInfo.userBalance = [NSString stringWithFormat:@"%d", [num integerValue]];
            
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    loaderInfo.extracted = [loaderInfo.userBalance length] > 0;
     */
}

@end
