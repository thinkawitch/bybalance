//
//  BBItemMts.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBItemMts.h"

@implementation BBItemMts

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
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //incorrect login/pass
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<div class=\"logon-result-block\">(.+)</div>" caseInsensitive:YES treatAsOneLine:YES];
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
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<h3>(.+)</h3>" caseInsensitive:YES treatAsOneLine:NO];
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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план: <strong>(.+)</strong>" caseInsensitive:YES treatAsOneLine:NO];
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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<span id=\"customer-info-balance\"><strong>(.+)</strong>" caseInsensitive:YES treatAsOneLine:NO];
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
        return [NSString stringWithFormat:@"%@\r\n+375%@\r\n%@\r\n%@", userTitle, username, userPlan, userBalance];
    }
    else 
    {
        return [NSString stringWithFormat:@"данные от МТС по +375%@ не получены", username];
    }
}

@end
