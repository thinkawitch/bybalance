//
//  BBLoaderNiks.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderNiks.h"

@implementation BBLoaderNiks

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://user.niks.by/"];
    
    //TODO viewstate should be readed from page before submit
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"dDwtOTM5ODc5MjcyOztsPExvZ2luSW1nQnRuOz4+LWAmSvmShzbE7AkSAWCVT7wVAJo=", @"__VIEWSTATE",
                             self.account.username, @"LoginTxt",
                             self.account.password, @"PasswordTxt",
                             @"37", @"LoginImgBtn.x",
                             @"12", @"LoginImgBtn.y",
                             nil];
    
    [self.httpClient POST:@"/Login.aspx" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self extractInfoFromHtml:operation.responseString];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
    
}


- (void) extractInfoFromHtml:(NSString *)html
{
    [super extractInfoFromHtml:html];
    return;
    
    //DDLogVerbose(@"%@", html);
    if (!html) return;
    
    //incorrect login/pass
    self.loaderInfo.incorrectLogin = ([html rangeOfString:@"id=\"MessageLabel\""].location != NSNotFound);
    //DDLogVerbose(@"incorrectLogin: %d", incorrectLogin);
    if (self.loaderInfo.incorrectLogin) return;
    
    NSArray * arr = nil;
    BOOL extracted = NO;
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Имя:</td>\\s+<td class=\"bgTableGray2\" width=\"50%\" align=\"left\">([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userTitle = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userTitle: %@", loaderInfo.userTitle);
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:</td>\\s*<td class=\"bgTableGray2\" width=\"50%\" align=\"left\">\\s*<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\\s*<tr>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userPlan = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userPlan: %@", loaderInfo.userPlan);
    
    //test balance value
    //html = [html stringByReplacingOccurrencesOfString:@"<b>0</b>" withString:@"<b>10 942</b>"];
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Баланс:</td>\\s*<td class=\"bgTableWhite2\" width=\"50%\" align=\"left\">\\s*<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\\s*<tr>\\s*<td nowrap><font color=red><b>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userBalance = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
    }
    //DDLogVerbose(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = extracted;
}

@end
