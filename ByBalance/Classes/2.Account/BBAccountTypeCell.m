//
//  BBAccountTypeCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBAccountTypeCell.h"

@interface BBAccountTypeCell ()
- (void) applyIpadChanges;
@end

@implementation BBAccountTypeCell

@synthesize accountType;

- (void) setupWithAccountType:(BBMAccountType*) type
{
    [self applyIpadChanges];
    
    self.accountType = type;
    lblTitle.text = type.name;
}

- (void) applyIpadChanges
{
    if (!APP_CONTEXT.isIpad || ipadChangesApplied) return;
    
    self.backgroundColor = [UIColor clearColor]; //universal app, ipad makes bg white
    
    ipadChangesApplied = YES;
}

@end
