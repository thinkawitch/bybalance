//
//  BBHistoryCommonCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBHistoryCommonCell.h"

@implementation BBHistoryCommonCell

- (void) setupWithHistory:(BBMBalanceHistory *) history
{
    [super setupWithHistory:history];
    

    lblDate.text = [NSDateFormatter localizedStringFromDate:history.date 
                                                  dateStyle:NSDateFormatterMediumStyle
                                                  timeStyle:NSDateFormatterShortStyle];

    if ([history.extracted boolValue])
    {
        lblBalance.text = [NSNumberFormatter localizedStringFromNumber:history.balance
                                                           numberStyle:NSNumberFormatterDecimalStyle];
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

@end
