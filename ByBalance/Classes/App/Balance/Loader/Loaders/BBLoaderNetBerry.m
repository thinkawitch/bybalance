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
    [self prepareHttpClient:@"https://user.nbr.by/"];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"0", @"midAuth",
                             self.account.username, @"user",
                             self.account.password, @"pswd",
                             nil];
    
    [self.httpClient POST:@"/bgbilling/webexecuter" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderNetBerry.onStep1");
    //DDLogVerbose(@"%@", html);
    
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

    [self.httpClient GET:@"/bgbilling/webexecuter?action=ShowBalance&mid=contract" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
    
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderNetBerry.onStep2");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    if (!html) return;
    
    //incorrect login/pass
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = YES;
        return;
    }
    
    NSArray * arr = nil;
    BOOL extracted = NO;
    
    //balance
    
    NSDecimalNumber * balanceOnMonthStart = nil;
    NSDecimalNumber * balanceOnMonthEnd = nil;
    NSDecimalNumber * balanceTotal = nil;
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Входящий остаток на начало месяца</th>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        balanceOnMonthStart = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
    }
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Исходящий остаток на конец месяца</th>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        balanceOnMonthEnd = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
    }
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Остаток средств</th>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        balanceTotal = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
        
    }
    
    if (nil != balanceTotal) self.loaderInfo.userBalance = balanceTotal;
    else if (nil != balanceOnMonthEnd) self.loaderInfo.userBalance = balanceOnMonthEnd;
    else if (nil != balanceOnMonthStart) self.loaderInfo.userBalance = balanceOnMonthStart;
    
    //DDLogVerbose(@"balance: %@", self.loaderInfo.userBalance);
    
    self.loaderInfo.extracted = extracted;
}

@end
