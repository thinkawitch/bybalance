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
    [self clearCookies:@"https://issa.diallog.by/cgi-bin/cgi.exe"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://issa.diallog.by/"]];
    [self setDefaultsForHttpClient];
    
    NSString * s2 = [self.account.username substringFromIndex:2];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"2", @"Lang",
                             s2, @"mobnum",
                             self.account.password, @"Password",
                             nil];
    
    [self.httpClient postPath:@"/cgi-bin/cgi.exe?function=is_login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response1 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        
        //cgi.exe?function=is_account
        if ([response1 rangeOfString:@"cgi.exe?function=is_account"].location == NSNotFound)
        {
            [self doFinish];
        }
        else
        {
            [self.httpClient getPath:@"/cgi-bin/cgi.exe?function=is_account" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *response2 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
                
                [self extractInfoFromHtml:response2];
                [self doFinish];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self doFinish];
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //NSLog(@"%@", html);
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Актуальный баланс:</td>\\s*<td class=light width=\"50%\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            buf = [buf stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            buf = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            self.loaderInfo.userBalance = buf;
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userBalance length] > 0;
}

@end
