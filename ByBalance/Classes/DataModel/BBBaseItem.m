//
//  BBBaseItem.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseItem.h"

@implementation BBBaseItem

@synthesize loginUrl;
@synthesize detailsUrl;
@synthesize username;
@synthesize password;

@synthesize isBanned;
@synthesize isExtracted;
@synthesize userTitle;
@synthesize userPlan;
@synthesize userBalance;

#pragma mark - ObjectLife

- (id) init
{
	self = [super init];
	if (self)
	{
        self.loginUrl = @"";
        self.detailsUrl = @"";
        self.username = @"";
        self.password = @"";
        
        self.isBanned = NO;
		self.isExtracted = NO;
        self.userTitle = @"";
        self.userPlan = @"";
        self.userBalance = @"";
	}
	
	return self;
}

- (void) dealloc
{
    self.loginUrl = nil;
    self.detailsUrl = nil;
    self.username = nil;
    self.password = nil;
    
    self.userTitle = nil;
    self.userPlan = nil;
    self.userBalance = nil;
    
    [super dealloc];
}

#pragma mark - Logic

- (void) extractFromHtml:(NSString *)html
{
    NSLog(@"BBBaseItem.extractFromHtml should override");
}

- (NSString *) fullDescription
{
    NSLog(@"BBBaseItem.fullDescription should override");

    return @"";
}

@end
