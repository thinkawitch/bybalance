//
//  BBHistoryAnitexCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/5/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBHistoryAnitexCell.h"

@implementation BBHistoryAnitexCell

- (void) setupWithHistory:(BBMBalanceHistory *) history
{
    [super setupWithHistory:history];
    
    
    lblDate.text = [NSDateFormatter localizedStringFromDate:history.date
                                                  dateStyle:NSDateFormatterMediumStyle
                                                  timeStyle:NSDateFormatterShortStyle];
    
    if ([history.incorrectLogin boolValue])
    {
        lblMegabytes.text = @"неправильный логин";
        lblDays.text = @"";
        lblCredit.text = @"";
        return;
    }
    else if (![history.extracted boolValue])
    {
        lblMegabytes.text = @"ошибка";
        lblDays.text = @"";
        lblCredit.text = @"";
        return;
    }
    
    if ([history.balance floatValue] == 0.0f)
    {
        lblMegabytes.text = [NSString stringWithFormat:@"мегабайт: %@ ", history.megabytes];
        lblDays.text = [NSString stringWithFormat:@"суток: %@", history.days];
        lblCredit.text = [NSString stringWithFormat:@"пакетов: %@", history.packages];
    }
    else
    {
        lblMegabytes.text = [NSString stringWithFormat:@"остаток: %@ ", history.balance];
        lblDays.text = [NSString stringWithFormat:@"кредит: %@", history.credit];
        lblCredit.text = @"";
    }
    
}

@end
