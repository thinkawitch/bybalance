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
    lblTitle.text = type.name;
    self.accountType = type;
}

@end
