//
//  BBItemTcm.m
//  ByBalance
//
//  Created by Admin on 16.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemTcm.h"

@implementation BBItemTcm

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
    
    if ([html isEqualToString:@"ERROR"] || [html isEqualToString:@"FORBIDDEN"])
    {
        self.incorrectLogin = YES;
        return;
    }
    
    /*
     5081;2703034;226203;0;1;
     
     Где:
     5081 - номер лицевого счета
     2703034 - логин
     226203 - баланс, руб.
     0 - кредит, руб.
     1 - статус интернета (0 - ОТКЛ, 1 - ВКЛ)
     */
    
    NSArray *arr = [html componentsSeparatedByString:@";"];
    if (!arr || [arr count] <3)
    {
        self.extracted = NO;
        return;
    }
    
    NSString * bal = [arr objectAtIndex:2];
    if (![APP_CONTEXT stringIsNumeric:bal])
    {
        self.extracted = NO;
        return;
    }
    self.userBalance = bal;
    
    NSLog(@"balance: %@", userBalance);
    
    
    self.extracted = YES;
}

- (NSString *) fullDescription
{
    if (extracted)
    {
        return [NSString stringWithFormat:@"%@\r\n%@", username, userBalance];
    }
    else
    {
        return [NSString stringWithFormat:@"данные от TCM по %@ не получены", username];
    }
}

@end
