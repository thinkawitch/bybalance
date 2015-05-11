//
//  BBTodayCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "BBTodayCell.h"

@implementation BBTodayCell

- (void) setupWithDictionary:(NSDictionary *) dict
{
    lblName.text = [dict objectForKey:@"name"];
    lblBalance.text = [dict objectForKey:@"balance"];
    
    //NSDate * date = [DATE_HELPER mysqlDateTimeToDate:[dict objectForKey:@"date"]];
    //lblDate.text = [DATE_HELPER formatSmartAsDayOrTime:date];
    
    NSString * strDate = [dict objectForKey:@"date"];
    if (!strDate || [strDate length] < 5)
    {
        lblDate.text = @"-";
    }
    else
    {
        NSDate * date = [DATE_HELPER mysqlDateTimeToDate:strDate];
        lblDate.text = date ? [DATE_HELPER formatSmartAsDayOrTime:date] : @"-";
    }
}

@end
