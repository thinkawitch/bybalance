//
//  BBLoaderDiallog.m
//  ByBalance2
//
//  Created by Andrew Sinkevitch on 10/20/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderDiallog.h"

@implementation BBLoaderDiallog

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://issa.diallog.by/"];
    
    NSString * s2 = [self.account.username substringFromIndex:2];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"2", @"Lang",
                             s2, @"mobnum",
                             self.account.password, @"Password",
                             nil];
    
    [self.httpClient POST:@"/cgi-bin/cgi.exe?function=is_login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response1 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        
        //cgi.exe?function=is_account
        if ([response1 rangeOfString:@"cgi.exe?function=is_account"].location == NSNotFound)
        {
            [self doFinish];
        }
        else
        {
            [self.httpClient GET:@"/cgi-bin/cgi.exe?function=is_account" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *response2 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
                
                [self extractInfoFromHtml:response2];
                [self doFinish];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
                [self doFinish];
            }];
        }
        
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
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Актуальный баланс:</td>\\s*<td class=light width=\"50%\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userBalance = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
    }
    //DDLogVerbose(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = extracted;
}

@end
