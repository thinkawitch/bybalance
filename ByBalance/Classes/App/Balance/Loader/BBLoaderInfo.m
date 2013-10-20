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
        self.userBalance = @"";
	}
	
	return self;
}

#pragma mark - Logic

- (NSString *) fullDescription
{
    return [NSString stringWithFormat:@"[%d/%d] %@ / %@ / %@", extracted, incorrectLogin, userTitle, userPlan, userBalance];
}

@end
