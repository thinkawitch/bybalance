//
//  BBItemNetBerry.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 21.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemNetBerry.h"

@implementation BBItemNetBerry

#pragma mark - ObjectLife

- (id) init
{
	self = [super init];
	if (self)
	{
        //
	}
	
	return self;
}

#pragma mark - Logic

- (void) extractFromHtml:(NSString *)html
{
    if (!html)
    {
        self.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        self.incorrectLogin = YES;
        self.extracted = NO;
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
            self.userBalance = [NSString stringWithFormat:@"%d", [num integerValue]];
            
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
        return [NSString stringWithFormat:@"данные от NetBerry по %@ не получены", username];
    }
}

@end
