//
//  BBItemByFly.m
//  ByBalance
//
//  Created by Admin on 12.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemByFly.h"

@implementation BBItemByFly

#pragma mark - Logic

- (void) extractFromHtml:(NSString *)html
{
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //incorrect login/pass
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<div class='alarma'>(.+)</div>" caseInsensitive:YES treatAsOneLine:YES];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.incorrectLogin = YES;
        }
    }
    NSLog(@"incorrectLogin: %d", incorrectLogin);
    
    if (incorrectLogin)
    {
        self.extracted = NO;
        return;
    }
    
    NSLog(@"%@", html);
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td class='title'>Ф.И.О.:</td><td>([^<]+)</td></tr>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userTitle = buf;
        }
    }
    NSLog(@"userTitle: %@", userTitle);
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td class='title'>Тариф:</td><td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userPlan = buf;
        }
    }
    NSLog(@"userPlan: %@", userPlan);
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий баланс:</td><td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    NSLog(@"balance: %@", userBalance);
    
    self.extracted = [userTitle length] > 0 && [userPlan length] > 0 && [userBalance length] > 0;
}

- (NSString *) fullDescription
{
    if (extracted)
    {
        return [NSString stringWithFormat:@"%@\r\n%@\r\n%@\r\n%@", userTitle, username, userPlan, userBalance];
    }
    else
    {
        return [NSString stringWithFormat:@"данные от ByFly по %@ не получены", username];
    }
}

@end
