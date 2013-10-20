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

- (void) startLoader
{
    [self clearCookies:self.baseUrl];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:self.baseUrl]];
    [self setDefaultsForHttpClient];

    [self.httpClient getPath:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

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
    NSString * captchaUrl = [NSString stringWithFormat:@"/img/_cap/items/%@", imgName];
    
    [self.httpClient getPath:captchaUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self onStep2:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderDamavik.onStep2");
    
    if (!isAtlant && !isDamavik)
    {
        [self doFinish];
        return;
    }

    NSString *formAction = [NSString stringWithFormat:@"%@about", self.baseUrl];
    NSDictionary *params = nil;

    if (isDamavik)
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  @"login", @"action__n18",
                  formAction, @"form_action_true",
                  self.account.username, @"login__n18",
                  self.account.password, @"password__n18",
                  nil];
    }
    else if (isAtlant)
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  @"login", @"action__n28",
                  formAction, @"form_action_true",
                  self.account.username, @"login__n28",
                  self.account.password, @"password__n28",
                  nil];
    }

    [self.httpClient postPath:self.baseUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep3:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
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
        self.loaderInfo.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    self.loaderInfo.incorrectLogin = ([html rangeOfString:@"<div class=\"redmsg mesg\"><div>Введенные данные неверны. Проверьте и повторите попытку.</div></div>"].location != NSNotFound);
    //NSLog(@"incorrectLogin: %d", loaderInfo.incorrectLogin);
    if (self.loaderInfo.incorrectLogin)
    {
        self.loaderInfo.extracted = NO;
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
            self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userBalance length] > 0;
}

@end
