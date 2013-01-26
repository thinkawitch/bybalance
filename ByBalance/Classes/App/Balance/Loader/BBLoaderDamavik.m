//
//  BBLoaderDamavik.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderDamavik.h"

@interface BBLoaderDamavik ()

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

- (void) doFail;
- (void) doSuccess:(NSString *)html;

@end

@implementation BBLoaderDamavik

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"https://issa.damavik.by/";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
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
    
    NSString * html = html = request.responseString;
    NSString * step = [request.userInfo objectForKey:@"step"];
    
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
    NSLog(@"BBLoaderDamavik.onStep1");
    //NSLog(@"%@", html);
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //search for captcha image
    
    NSString * imgName = nil;
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<img src=\"/img/_cap/items/([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            imgName = buf;
        }
    }
    
    NSLog(@"imgName: %@", imgName);
    
    if (!imgName)
    {
        [self doFail];
        return;
    }
    
    //load captcha image to get cookies
    
    NSString * captchaUrl = @"https://issa.damavik.by/img/_cap/items/";
    captchaUrl = [captchaUrl stringByAppendingString:imgName];
    
    NSURL * url = [NSURL URLWithString:captchaUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    //start request
    [request startAsynchronous];
}

- (void) onStep2:(NSString *)html
{
    NSLog(@"BBLoaderDamavik.onStep2");
    

    NSString * loginUrl = @"https://issa.damavik.by/";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setPostValue:@"login" forKey:@"action__n18"];
    [request setPostValue:@"https://issa.damavik.by/about" forKey:@"form_action_true"];
    [request setPostValue:account.username forKey:@"login__n18"];
    [request setPostValue:account.password forKey:@"password__n18"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"3", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    //start request
    [request startAsynchronous];
}

- (void) onStep3:(NSString *)html
{
    NSLog(@"BBLoaderDamavik.onStep3");
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
