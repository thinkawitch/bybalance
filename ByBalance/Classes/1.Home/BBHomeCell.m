//
//  BBHomeCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBHomeCell.h"

@implementation BBHomeCell

@synthesize account;

- (void) setupWithAccount:(BBMAccount*) anAccount;
{
    self.account = anAccount;
    
    lblType.text = account.type.name;
    lblName.text = account.username;
}

- (void) dealloc
{
    self.account = nil;
    
    [super dealloc];
}

@end
