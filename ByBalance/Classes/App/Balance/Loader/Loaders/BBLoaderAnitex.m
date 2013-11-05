//
//  BBLoaderAnitex.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/5/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderAnitex.h"

@implementation BBLoaderAnitex

#pragma mark - Logic

- (void) startLoader
{
    [self clearCookies:@"https://stat.anitex.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://stat.anitex.by/"]];
    [self setDefaultsForHttpClient];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.account.username, @"username",
                             self.account.password, @"password",
                             @"dialup", @"type",
                             nil];
    
    [self.httpClient postPath:@"/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response2 = [[NSString alloc] initWithData:responseObject encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingKOI8_R)];
        
        [self extractInfoFromHtml:response2];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [self doFinish];
    }];
    
}


- (void) extractInfoFromHtml:(NSString *)html
{
    //NSLog(@"%@", html);
    
    //incorrect login/pass
    self.loaderInfo.incorrectLogin = ([html rangeOfString:@"Ошибка авторизации"].location != NSNotFound);
    if (self.loaderInfo.incorrectLogin)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSString * buf = nil;
    NSArray * arr = nil;
    BOOL extracted = NO;
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Неактивированных пакетов</td>\\s*<td>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
        self.loaderInfo.userPackages = [PRIMITIVE_HELPER numberIntegerValue:buf];
    }
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий пакет, осталось МегаБайт</td>\\s*<td>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        extracted = YES;
        self.loaderInfo.userMegabytes = [self decimalNumberFromString:[arr objectAtIndex:0]];
    }
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий пакет, осталось суток</td>\\s*<td>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        extracted = YES;
        self.loaderInfo.userDays = [self decimalNumberFromString:[arr objectAtIndex:0]];
    }
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Кредит</td>\\s*<td>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        extracted = YES;
        self.loaderInfo.userCredit = [self decimalNumberFromString:[arr objectAtIndex:0]];
    }
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Остаток</td>\\s*<td>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        extracted = YES;
        self.loaderInfo.userBalance = [self decimalNumberFromString:[arr objectAtIndex:0]];
    }
    
    NSLog(@"packages: %@", self.loaderInfo.userPackages);
    NSLog(@"megabytes: %@", self.loaderInfo.userMegabytes);
    NSLog(@"days: %@", self.loaderInfo.userDays);
    NSLog(@"credit: %@", self.loaderInfo.userCredit);
    NSLog(@"ostatok: %@", self.loaderInfo.userBalance);
    
    self.loaderInfo.extracted = extracted;
}

@end
