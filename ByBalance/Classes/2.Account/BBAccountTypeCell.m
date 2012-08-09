//
//  BBAccountTypeCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBAccountTypeCell.h"

@implementation BBAccountTypeCell

@synthesize accountType;

- (void) setupWithAccountType:(BBMAccountType*) type
{
    self.accountType = type;
    
    lblTitle.text = type.name;
}

- (void) dealloc
{
    self.accountType = nil;
    
    [super dealloc];
}

@end
