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

- (void) doFail;
- (void) doSuccess:(NSString *)html;

@end

@implementation BBLoaderNetBerry

#pragma mark - ObjectLife

- (void) dealloc
{
    [super dealloc];
}

- (ASIFormDataRequest *) prepareRequest
{
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
    NSLog(@"BBLoaderNetBerry.onStep1");
    //NSLog(@"%@", html);
    
    //Ошибка при авторизации
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        [self doSuccess:html];
        return;
    }
    
    //ссылка на страницу баланса
    if ([html rangeOfString:@"?action=ShowBalance&mid=contract"].location == NSNotFound)
    {
        [self doFail];
        return;
    }
    
    //https://user.nbr.by/bgbilling/webexecuter?action=ShowBalance&mid=contract
    
    NSURL * url = [NSURL URLWithString:@"https://user.nbr.by/bgbilling/webexecuter?action=ShowBalance&mid=contract"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    
    [request addRequestHeader:@"Host" value:@"user.nbr.by"];
    [request addRequestHeader:@"Referer" value:@"https://user.nbr.by/bgbilling/webexecuter"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    [request startAsynchronous];
    
}

- (void) onStep2:(NSString *)html
{
    NSLog(@"BBLoaderNetBerry.onStep2");
    //NSLog(@"%@", html);
    
    [self doSuccess:html];
}

- (void) doFail
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderFail:)])
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, nil]];
        
        [self.delegate balanceLoaderFail:info];
    }
    
    [self markDone];
}

- (void) doSuccess:(NSString *)html
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderSuccess:)])
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, html, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyHtml, nil]];
        
        [self.delegate balanceLoaderSuccess:info];
    }
    
    [self markDone];
}

@end
