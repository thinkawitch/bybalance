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
    
    NSString * menuMarker = @"";
    NSString * menuMarker1 = @"_root/USER_INFO";
    NSString * menuMarker2 = @"_root/MENU0";
    
    BOOL loggedIn = false;
    //check if we logged in
    if ([html rangeOfString:menuMarker1].location != NSNotFound)
    {
        menuMarker = menuMarker1;
        loggedIn = YES;
    }
    else if ([html rangeOfString:menuMarker2].location != NSNotFound)
    {
        menuMarker = menuMarker2;
        loggedIn = YES;
    }

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
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:\\s*</td><td class=\"INFO\"[^>]*>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userPlan = buf;
        }
    }
    NSLog(@"userPlan: %@", userPlan);
    
    //balance 1
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий баланс:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    
    if (!self.userBalance || [self.userBalance length] < 1)
    {
        //balance 2
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Баланс:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            buf = [arr objectAtIndex:0];
            if (nil != buf && [buf length] > 0)
            {
                self.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        }
    }
    
    if (!self.userBalance || [self.userBalance length] < 1)
    {
        //balance 3
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Начисления\\s*абонента\\*:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            buf = [arr objectAtIndex:0];
            if (nil != buf && [buf length] > 0)
            {
                self.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        }
    }
    NSLog(@"balance: %@", userBalance);
    
    self.extracted = [userPlan length] > 0 && [userBalance length] > 0;
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