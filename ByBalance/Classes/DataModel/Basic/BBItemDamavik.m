//
//  BBItemDamavik.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemDamavik.h"

@implementation BBItemDamavik


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
    //NSLog(@"%@", html);
    
    if (!html)
    {
        self.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    self.incorrectLogin = ([html rangeOfString:@"<div class=\"redmsg mesg\"><div>Введенные данные неверны. Проверьте и повторите попытку.</div></div>"].location != NSNotFound);
    NSLog(@"incorrectLogin: %d", incorrectLogin);
    if (incorrectLogin)
    {
        self.extracted = NO;
        return;
    }
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //userTitle - absent
    
    //userPlan - absent
    
    //test balance value
    //html = [html stringByReplacingOccurrencesOfString:@"<td>0</td>" withString:@"<td>5224.55</td>"];
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Состояние счета</td>\\s+<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    NSLog(@"balance: %@", userBalance);
    
    self.extracted = [userBalance length] > 0;
}

- (NSString *) fullDescription
{
    if (extracted)
    {
        return [NSString stringWithFormat:@"%@\r\n%@", username, userBalance];
    }
    else
    {
        return [NSString stringWithFormat:@"данные от Шпаркі Дамавік по %@ не получены", username];
    }
}

@end
