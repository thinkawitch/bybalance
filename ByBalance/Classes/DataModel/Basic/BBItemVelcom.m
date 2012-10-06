//
//  BBItemVelcom.m
//  ByBalance
//
//  Created by Admin on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBItemVelcom.h"

@implementation BBItemVelcom

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
    
    
    BOOL loggedIn = ([html rangeOfString:@"_root/USER_INFO"].location != NSNotFound);
    if (!loggedIn)
    {
        //incorrect login/pass
        self.incorrectLogin = ([html rangeOfString:@"INFO_Error_caption"].location != NSNotFound);
        NSLog(@"incorrectLogin: %d", incorrectLogin);
        
        if (incorrectLogin)
        {
            self.extracted = NO;
            return;
        }
    }
    
    
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"ФИО:</td><td class=\"INFO\">([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:\\s*</td><td class=\"INFO\" width=\"200px\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий баланс:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
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
        return [NSString stringWithFormat:@"данные от Velcom по %@ не получены", username];
    }
}

@end