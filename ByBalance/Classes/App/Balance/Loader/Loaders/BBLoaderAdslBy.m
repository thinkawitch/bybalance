//
//  BBLoaderAdslBy.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15/10/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//

#import "BBLoaderAdslBy.h"

@implementation BBLoaderAdslBy

- (void) startLoader
{
    [self prepareHttpClient:@"https://www.adsl.by/"];
    
    [self.httpClient.requestSerializer setAuthorizationHeaderFieldWithUsername:self.account.username password:self.account.password];
    
    [self.httpClient GET:@"/001.htm" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        [self extractInfoFromHtml:text];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        if ([error.localizedDescription rangeOfString:@"(401)"].location != NSNotFound) self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
    }];
}


- (void) extractInfoFromHtml:(NSString *)html
{
    DDLogVerbose(@"%@", html);
    if (!html) return;
    
    NSString * buf = nil;
    NSMutableArray * bonuses = [[NSMutableArray alloc] initWithCapacity:2];
    NSArray * arr = nil;
    BOOL extracted = NO;
    
    //Включен
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@">Аккаунт</td>\\s+<td[^>]+><b>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if ([buf isKindOfClass:[NSString class]]) [bonuses addObject:buf];
    }
    
    //осталось
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td class='left'></td>\\s+<td[^>]+>осталось\\s+<b>([^<]+)</b></td>\\s+</tr>\\s+<tr class=\"sub last_pay\">" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if ([buf isKindOfClass:[NSString class]]) [bonuses addObject:[NSString stringWithFormat:@"осталось %@", buf]];
    }
    
    if ([bonuses count]>0) self.loaderInfo.bonuses = [bonuses componentsJoinedByString:@", "];
    DDLogVerbose(@"bonuses %@", self.loaderInfo.bonuses);
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Осталось трафика на сумму</td>\\s+<td[^>]+><b>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userBalance = [self decimalNumberFromString:[arr objectAtIndex:0]];
        extracted = YES;
    }
    
    self.loaderInfo.extracted = extracted;
}

@end
