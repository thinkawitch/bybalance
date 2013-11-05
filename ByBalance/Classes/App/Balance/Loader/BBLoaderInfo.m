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

@synthesize userMegabytes;
@synthesize userMinutes;
@synthesize userSms;

@synthesize userPackages;
@synthesize userDays;

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
        
        self.userBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
        
        self.userMegabytes = [NSNumber numberWithInt:0];
        self.userMinutes = [NSNumber numberWithInt:0];
        self.userSms = [NSNumber numberWithInt:0];
        
        self.userPackages = [NSNumber numberWithInt:0];
        self.userDays = [NSNumber numberWithInt:0];
	}
	
	return self;
}

#pragma mark - Logic

- (NSString *) fullDescription
{
    return [NSString stringWithFormat:@"[%d/%d] %@", extracted, incorrectLogin, userBalance];
}

@end
