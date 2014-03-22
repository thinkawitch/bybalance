//
//  BBLoaderByFly.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderByFly.h"

@interface BBLoaderByFly ()
@end


@implementation BBLoaderByFly

#pragma mark - Logic

- (void) startLoader
{
    [self clearCookies:@"https://issa.beltelecom.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://issa.beltelecom.by/"]];
    [self setDefaultsForHttpClient];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.account.username, @"oper_user",
                            self.account.password, @"passwd",
                            @"/main.html", @"redirect",
                            nil];
    //DDLogVerbose(@"%@", params);
  
    [self.httpClient postPath:@"main.html" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSString *response1 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        NSString * response = operation.responseString;
        //DDLogVerbose(@"Response:\n%@", response);
        
        [self extractInfoFromHtml:response];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    NSArray * arr = nil;
    BOOL extracted = NO;
    //DDLogVerbose(@"%@", html);
    
    if ([html rangeOfString:@"name=\"oper_user\""].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = true;
        return;
    }
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Актуальный баланс:\\s*<b>\\s*([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userBalance = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
    }
    //DDLogVerbose(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = extracted;
}

@end
