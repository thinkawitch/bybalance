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
            
            self.userBalance = buf;
        }
    }
    NSLog(@"balance: %@", userBalance);
    
    self.extracted = [userBalance length] > 0;
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
