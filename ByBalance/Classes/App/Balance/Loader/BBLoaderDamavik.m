//
//  BBLoaderDamavik.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderDamavik.h"

@interface BBLoaderDamavik ()

@property (strong, readwrite) NSString * baseUrl;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

@end

@implementation BBLoaderDamavik

#pragma mark - Logic

- (void) actAsDamavik
{
    self.baseUrl = @"https://issa.damavik.by/";
    isDamavik = YES;
}

- (void) actAsAtlantTelecom
{
    self.baseUrl = @"https://issa2b.telecom.by/";
    isAtlant = YES;
}

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = self.baseUrl;
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    return request;
}


#pragma mark - ASIHTTPRequestDelegate


- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestFinished", [self class]);
    
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
        [self doFinish];
    }
}


#pragma mark - Logic

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderDamavik.onStep1");
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
    
    //NSLog(@"imgName: %@", imgName);
    
    if (!imgName)
    {
        [self doFinish];
        return;
    }
    
    //load captcha image to get cookies
    
    //NSString * captchaUrl = @"https://issa.damavik.by/img/_cap/items/";
    NSString * captchaUrl = [NSString stringWithFormat:@"%@img/_cap/items/", self.baseUrl];
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
    //NSLog(@"BBLoaderDamavik.onStep2");
    
    NSString * loginUrl = self.baseUrl;
    NSString * formAction = [NSString stringWithFormat:@"%@about", self.baseUrl];
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    if (isDamavik)
    {
        [request setPostValue:@"login" forKey:@"action__n18"];
        //[request setPostValue:@"https://issa.damavik.by/about" forKey:@"form_action_true"];
        [request setPostValue:formAction forKey:@"form_action_true"];
        [request setPostValue:account.username forKey:@"login__n18"];
        [request setPostValue:account.password forKey:@"password__n18"];
    }
    if (isAtlant)
    {
        [request setPostValue:@"login" forKey:@"action__n28"];
        [request setPostValue:formAction forKey:@"form_action_true"];
        [request setPostValue:account.username forKey:@"login__n28"];
        [request setPostValue:account.password forKey:@"password__n28"];
    }
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"3", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    //start request
    [request startAsynchronous];
}

- (void) onStep3:(NSString *)html
{
    //NSLog(@"BBLoaderDamavik.onStep3");
    //NSLog(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    //NSLog(@"%@", html);
    
    if (!html)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    loaderInfo.incorrectLogin = ([html rangeOfString:@"<div class=\"redmsg mesg\"><div>Введенные данные неверны. Проверьте и повторите попытку.</div></div>"].location != NSNotFound);
    //NSLog(@"incorrectLogin: %d", loaderInfo.incorrectLogin);
    if (loaderInfo.incorrectLogin)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //userTitle - absent
    
    //userPlan - absent
    
    //test balance value
    //html = [html stringByReplacingOccurrencesOfString:@"<td>0</td>" withString:@"<td>5224.55</td>"];
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Состояние счета</td>\\s+<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    loaderInfo.extracted = [loaderInfo.userBalance length] > 0;
}

@end
