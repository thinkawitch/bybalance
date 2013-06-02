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
    lblName.text = account.nameLabel;
    
    BBMBalanceHistory * bh = account.lastGoodBalance;
    if (bh)
    {
        lblDate.text = [NSDateFormatter localizedStringFromDate:bh.date 
                                                      dateStyle:NSDateFormatterMediumStyle
                                                      timeStyle:NSDateFormatterNoStyle];
        
        lblBalance.text = [NSNumberFormatter localizedStringFromNumber:bh.balance
                                                           numberStyle:kCFNumberFormatterDecimalStyle];
    }
    else 
    {
        lblDate.text = @"";
        lblBalance.text = @"не обновлялся";
    }
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
}

- (void) dealloc
{
    self.account = nil;
    
    [super dealloc];
}

@end
