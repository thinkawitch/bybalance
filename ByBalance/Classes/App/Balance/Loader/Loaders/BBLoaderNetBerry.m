//
//  BBLoaderNetBerry.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 21.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderNetBerry.h"

@interface BBLoaderNetBerry ()

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end


@implementation BBLoaderNetBerry

#pragma mark - Logic

- (void) startLoader
{
    [self clearCookies:@"https://user.nbr.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://user.nbr.by/"]];
    [self setDefaultsForHttpClient];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"0", @"midAuth",
                             self.account.username, @"user",
                             self.account.password, @"pswd",
                             nil];
    
    [self.httpClient postPath:@"/bgbilling/webexecuter" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderNetBerry.onStep1");
    //NSLog(@"%@", html);
    
    //Ошибка при авторизации
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    //ссылка на страницу баланса
    if ([html rangeOfString:@"?action=ShowBalance&mid=contract"].location == NSNotFound)
    {
        [self doFinish];
        return;
    }
    
    //https://user.nbr.by/bgbilling/webexecuter?action=ShowBalance&mid=contract

    [self.httpClient getPath:@"/bgbilling/webexecuter?action=ShowBalance&mid=contract" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
    
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderNetBerry.onStep2");
    //NSLog(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{

    if (!html)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = YES;
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //balance
    // <th>Исходящий остаток на конец месяца</th><td>22 539.06</td>
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Исходящий остаток на конец месяца</th>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            buf = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:buf];
            self.loaderInfo.userBalance = [NSString stringWithFormat:@"%d", [num integerValue]];
            
        }
    }
    //NSLog(@"balance: %@", self.loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userBalance length] > 0;
}

@end
