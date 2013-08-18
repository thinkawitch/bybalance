//
//  BBLoaderCosmosTV.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 23.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderCosmosTV.h"

@interface BBLoaderCosmosTV ()

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

@end

@implementation BBLoaderCosmosTV

#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL * url = [NSURL URLWithString:@"http://cosmostv.by/subscribers/login/?process"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    [request addRequestHeader:@"Referer" value:@"http://cosmostv.by/"];
    
    [request addPostValue:account.username forKey:@"login"];
    [request addPostValue:account.password forKey:@"password"];
    [request addPostValue:@"1" forKey:@"doit!"];
    [request addPostValue:@"1" forKey:@"ajax"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    return request;
}


#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestFinished", [self class]);
    
    NSString * step = [request.userInfo objectForKey:@"step"];
    NSString * html = request.responseString;
    
    
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
}


#pragma mark - Logic

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderCosmosTV.onStep1");
    //NSLog(@"%@", html);
    
    NSString * jsonString = [NSString stringWithFormat:@"%@", html];
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    
    if (![jsonObject isKindOfClass:[NSDictionary class]])
    {
        //это не json
        [self doFinish];
        return;
    }
        
    NSDictionary * jsonDictionary = (NSDictionary *)jsonObject;
    
    NSString * redirect = [jsonDictionary objectForKey:@"redirect"];
    if (!redirect)
    {
        //авторизация не прошла
        loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cosmostv.by%@", redirect]];
    ASIFormDataRequest * request = [self requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    [request startAsynchronous];
    
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderCosmosTV.onStep2");
    //NSLog(@"%@", html);
    
    //showServices(this, "101932108", "41263"
    //http://cosmostv.by/json/subscribers/account/cabinet/?contract=101932108
    
    
    NSArray * arr = nil;
    NSString * buf = nil;
    NSDecimalNumber * num = nil;
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"showServices\\(this,\\s*\"([^\"]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            buf = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            num = [NSDecimalNumber decimalNumberWithString:buf];
            
        }
    }
    
    if (num)
    {
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cosmostv.by/json/subscribers/account/cabinet/?contract=%@", num]];
        ASIFormDataRequest * request = [self requestWithURL:url];
        
        request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"3", nil]
                                                       forKeys:[NSArray arrayWithObjects:@"step", nil]];
        
        [request startAsynchronous];
    }
    else
    {
        [self doFinish];
    }
    
}

- (void) onStep3:(NSString *)html
{
    //NSLog(@"BBLoaderCosmosTV.onStep3");
    //NSLog(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    if (!html)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSString * jsonString = [NSString stringWithFormat:@"%@", html];
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    
    if (![jsonObject isKindOfClass:[NSDictionary class]])
    {
        //это не json
        loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary * dict = (NSDictionary *) jsonObject;
    NSArray * services = [dict objectForKey:@"services"];
    if (!services || [services count] < 1)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary * service1 = [services objectAtIndex:0];
    if (![service1 isKindOfClass:[NSDictionary class]])
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSString * pbalance = [service1 objectForKey:@"pbalance"];
    if (!pbalance)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:pbalance];
    loaderInfo.userBalance = [NSString stringWithFormat:@"%d", [num integerValue]];
    
    loaderInfo.extracted = [loaderInfo.userBalance length] > 0;
}

@end
