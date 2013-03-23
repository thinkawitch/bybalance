//
//  BBItemNiks.m
//  ByBalance
//
//  Created by Admin on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemNiks.h"

@implementation BBItemNiks

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
    //NSLog(@"%@", html);
    
    if (!html)
    {
        self.extracted = NO;
        return;
    }
    
    //incorrect login/pass
    self.incorrectLogin = ([html rangeOfString:@"id=\"MessageLabel\""].location != NSNotFound);
    NSLog(@"incorrectLogin: %d", incorrectLogin);
    if (incorrectLogin)
    {
        self.extracted = NO;
        return;
    }
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Имя:</td>\\s+<td class=\"bgTableGray2\" width=\"50%\" align=\"left\">([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:</td>\\s*<td class=\"bgTableGray2\" width=\"50%\" align=\"left\">\\s*<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\\s*<tr>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userPlan = buf;
        }
    }
    NSLog(@"userPlan: %@", userPlan);
    
    //test balance value
    //html = [html stringByReplacingOccurrencesOfString:@"<b>0</b>" withString:@"<b>10 942</b>"];
    
    //balance
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Баланс:</td>\\s*<td class=\"bgTableWhite2\" width=\"50%\" align=\"left\">\\s*<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\\s*<tr>\\s*<td nowrap><font color=red><b>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
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
        return [NSString stringWithFormat:@"данные от НИКС по %@ не получены", username];
    }
}

@end
