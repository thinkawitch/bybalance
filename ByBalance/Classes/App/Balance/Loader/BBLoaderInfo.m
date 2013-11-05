//
//  BBBalanceInfo.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 18.08.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderInfo.h"

@implementation BBLoaderInfo

@synthesize incorrectLogin;
@synthesize extracted;

@synthesize userTitle;
@synthesize userPlan;

@synthesize userBalance;

@synthesize userPackages;
@synthesize userMegabytes;
@synthesize userDays;
@synthesize userCredit;

@synthesize userMinutes;
@synthesize userSms;


#pragma mark - ObjectLife

- (id) init
{
	self = [super init];
	if (self)
	{
        self.incorrectLogin = NO;
		self.extracted = NO;
        
        self.userTitle = @"";
        self.userPlan = @"";
        
        self.userBalance = [[NSDecimalNumber alloc] initWithInt:0];
        
        self.userPackages = [NSNumber numberWithInt:0];
        self.userMegabytes = [[NSDecimalNumber alloc] initWithInt:0];
        self.userDays = [[NSDecimalNumber alloc] initWithInt:0];
        self.userCredit = [[NSDecimalNumber alloc] initWithInt:0];
        
        self.userMinutes = [NSNumber numberWithInt:0];
        self.userSms = [NSNumber numberWithInt:0];
	}
	
	return self;
}

#pragma mark - Logic

- (NSString *) fullDescription
{
    return [NSString stringWithFormat:@"[%d/%d] %@", extracted, incorrectLogin, userBalance];
}

@end
