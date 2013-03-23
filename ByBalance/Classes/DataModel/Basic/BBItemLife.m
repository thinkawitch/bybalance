//
//  BBItemLife.m
//  ByBalance
//
//  Created by Admin on 17.11.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBItemLife.h"

@implementation BBItemLife

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
    
    //NSLog(@"%@", html);
    
    BOOL loggedIn = ([html rangeOfString:@"/Account.aspx/Logoff"].location != NSNotFound);
    if (!loggedIn)
    {
        //incorrect login/pass
        self.incorrectLogin = ([html rangeOfString:@"errorMessage"].location != NSNotFound);
        NSLog(@"incorrectLogin: %d", incorrectLogin);
        
        if (incorrectLogin)
        {
            self.extracted = NO;
            return;
        }
    }
    
    
    
    //userTitle
    /*
     <div class="divBold">Фамилия:</div>
     <div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Фамилия:\\s*</div>\\s*<div>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userTitle = [buf stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    NSLog(@"userTitle: %@", userTitle);
    
    //userPlan
    /*
     <div class="divBold">
     Тарифный план:
     </div>
     <div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:\\s*</div>\\s*<div>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.userPlan = [buf stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    NSLog(@"userPlan: %@", userPlan);
    
    //balance
    /*
     <div class="divBold">
     Текущий основной баланс: *
     </div>
     <div>
     7 500,00р.
     </div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий основной баланс: \\*\\s*</div>\\s*<div>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            //self.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            self.userBalance = [buf stringByReplacingRegexPattern:@"[^0-9.,]" withString:@""];
        }
    }
    NSLog(@"balance: %@", userBalance);
    
    self.extracted = /*[userTitle length] > 0 &&*/ [userPlan length] > 0 && [userBalance length] > 0;
}

- (NSString *) fullDescription
{
    if (extracted)
    {
        return [NSString stringWithFormat:@"%@\r\n%@\r\n%@", username, userPlan, userBalance];
    }
    else
    {
        return [NSString stringWithFormat:@"данные от Life по %@ не получены", username];
    }
}

@end
