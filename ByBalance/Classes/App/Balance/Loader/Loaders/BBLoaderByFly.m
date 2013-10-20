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
    [self clearCookies:@"https://issa.beltelecom.by/cgi-bin/cgi.exe"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://issa.beltelecom.by/"]];
    [self setDefaultsForHttpClient];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.account.username, @"mobnum",
                            self.account.password, @"Password",
                            nil];
    //NSLog(@"%@", params);
  
    [self.httpClient postPath:@"/cgi-bin/cgi.exe?function=is_login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response1 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        //NSString * response1 = operation.responseString;
        //NSLog(@"Response1:\n%@", response1);
        
        //cgi.exe?function=is_account
        if ([response1 rangeOfString:@"cgi.exe?function=is_account"].location == NSNotFound)
        {
            [self doFinish];
        }
        else
        {
            [self.httpClient getPath:@"/cgi-bin/cgi.exe?function=is_account" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *response2 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
                //NSString * response2 = operation.responseString;
                //NSLog(@"Response2:\n%@", response2);
                
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
