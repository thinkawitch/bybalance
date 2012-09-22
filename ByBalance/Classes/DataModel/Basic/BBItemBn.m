//
//  BBItemBn.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 06/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBItemBn.h"

@implementation BBItemBn

#pragma mark - ObjectLife

- (id) init
{
	self = [super init];
	if (self)
	{
        //self.loginUrl = @"http://ui.bn.by/index.php?mode=login";
	}
	
	return self;
}

#pragma mark - Logic

- (void) extractFromHtml:(NSString *)html
{
    NSString * buf = @"";
    
    //ban
    NSArray * arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<div class='alarma'>(.+)</div>" caseInsensitive:YES treatAsOneLine:YES];
    if (arr && [arr count] == 1) 
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.isBanned = YES;
        }
    }
    NSLog(@"isBanned: %d", isBanned);
    
    if (isBanned)
    {
        self.isExtracted = NO;
        return;
    }
    
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
    
    self.isExtracted = [userTitle length] > 0 && [userPlan length] > 0 && [userBalance length] > 0;
}

- (NSString *) fullDescription
{
    if (isExtracted)
    {
        return [NSString stringWithFormat:@"%@\r\n%@\r\n%@\r\n%@", userTitle, username, userPlan, userBalance];
    }
    else 
    {
        return [NSString stringWithFormat:@"данные от ДС по %@ не получены", username];
    }
}

@end