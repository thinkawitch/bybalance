//
//  BBLoaderMts.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderMts.h"

@interface BBLoaderMts ()

@property (nonatomic,strong) NSString * paramViewState;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end


@implementation BBLoaderMts

@synthesize paramViewState;

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://ihelper.mts.by/"];
    
    [self.httpClient GET:@"/SelfCare/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderMts.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSArray * arr = nil;
    
    //try to detect session
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"id=\"__VIEWSTATE\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.paramViewState = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    
    //DDLogVerbose(@"paramViewState: %@", self.paramViewState);
    
    if (!self.paramViewState)
    {
        [self doFinish];
        return;
    }

    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.paramViewState, @"__VIEWSTATE",
                             self.account.username, @"ctl00$MainContent$tbPhoneNumber",
                             self.account.password, @"ctl00$MainContent$tbPassword",
                             @"Войти", @"ctl00$MainContent$btnEnter",
                             nil];
    
    [self.httpClient POST:@"/SelfCare/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderMts.onStep2");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    NSString * buf = nil;
    NSArray * arr = nil;
    BOOL extracted = NO;
    
    //incorrect login/pass
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<div class=\"logon-result-block\">(.+)</div>" caseInsensitive:YES treatAsOneLine:YES];
    if (arr && [arr count] == 1)
    {
        buf = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
        if ([buf length] > 0)
        {
            self.loaderInfo.incorrectLogin = YES;
            return;
        }
    }
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<h3>(.+)</h3>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userTitle = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план: <strong>(.+)</strong>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userPlan = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<span id=\"customer-info-balance\"><strong>(.+)</strong>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userBalance = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
    }
    
    self.loaderInfo.extracted = extracted;
}

@end
