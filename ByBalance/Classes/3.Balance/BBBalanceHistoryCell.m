//
//  BBBalanceHistoryCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceHistoryCell.h"

@implementation BBBalanceHistoryCell

@synthesize history;

- (void) setupWithHistory:(BBMBalanceHistory *) aHistory;
{
    self.history = aHistory;
    

    lblDate.text = [NSDateFormatter localizedStringFromDate:history.date 
                                                  dateStyle:NSDateFormatterMediumStyle
                                                  timeStyle:NSDateFormatterShortStyle];

    if ([history.extracted boolValue])
    {
        lblBalance.text = [NSNumberFormatter localizedStringFromNumber:history.balance
                                                       numberStyle:kCFNumberFormatterDecimalStyle];
    }
    else if ([history.incorrectLogin boolValue])
    {
        lblBalance.text = @"неправильный логин";
    }
    else
    {
        lblBalance.text = @"ошибка";
    }
}

- (void) dealloc
{
    self.history = nil;
    
    [super dealloc];
}

@end
