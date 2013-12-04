//
//  BBLoaderLife.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17.11.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderLife.h"

@interface BBLoaderLife ()

@end

@implementation BBLoaderLife

#pragma mark - Logic

- (void) startLoader
{
    [self clearCookies:@"https://issa.life.com.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://issa.life.com.by/"]];
    [self setDefaultsForHttpClient];
    
    NSString * s1 = [self.account.username substringToIndex:2];
    NSString * s2 = [self.account.username substringFromIndex:2];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             s1, @"Code",
                             self.account.password, @"Password",
                             s2, @"Phone",
                             nil];
    
    [self.httpClient postPath:@"/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self extractInfoFromHtml:operation.responseString];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        //[self doFinish];
        
        [self clearCookies:@"https://issa2.life.com.by/"];
        self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://issa2.life.com.by/"]];
        [self setDefaultsForHttpClient];
        
        [self.httpClient postPath:@"/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self extractInfoFromHtml:operation.responseString];
            [self doFinish];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
            [self doFinish];
        }];
    }];
}



- (void) extractInfoFromHtml:(NSString *)html
{
    NSArray * arr = nil;
    BOOL extracted = NO;
    
    //DDLogVerbose(@"%@", html);
    
    BOOL loggedIn = ([html rangeOfString:@"/Account.aspx/Logoff"].location != NSNotFound);
    if (!loggedIn)
    {
        //incorrect login/pass
        self.loaderInfo.incorrectLogin = ([html rangeOfString:@"errorMessage"].location != NSNotFound);
        //DDLogVerbose(@"incorrectLogin: %d", incorrectLogin);
        
        if (self.loaderInfo.incorrectLogin) return;
    }
    
    
    //userTitle
    /*
     <div class="divBold">Фамилия:</div>
     <div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Фамилия:\\s*</div>\\s*<div>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userTitle = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userTitle: %@", loaderInfo.userTitle);
    
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
        self.loaderInfo.userPlan = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userPlan: %@", loaderInfo.userPlan);
    
    //balance
    /*
     <div class="divBold">
     Текущий основной баланс: *
     </div>
     <div>
     7 500,00р.
     </div>
     */
    
    /*
    html = @"<div>\
    <div class=\"divBold\">\
    Текущий основной баланс: *\
    </div> \
    <div> \
    -97&nbsp;931,14р. \
    </div> \
    </div>";
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий основной баланс: \\*\\s*</div>\\s*<div>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userBalance = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
        
    }
    //DDLogVerbose(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = extracted;
}

@end
