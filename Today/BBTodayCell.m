//
//  BBTodayCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "BBTodayCell.h"
#import "IDDateHelper.h"

@implementation BBTodayCell

- (void) setupWithDictionary:(NSDictionary *) dict
{
    lblName.text = [dict objectForKey:@"name"];
    lblBalance.text = [dict objectForKey:@"balance"];
    
    //NSDate * date = [[IDDateHelper sharedIDDateHelper] mysqlDateTimeToDate:[dict objectForKey:@"date"]];
    //lblDate.text = [[IDDateHelper sharedIDDateHelper] formatSmartAsDayOrTime:date];
    
    NSString * strDate = [dict objectForKey:@"date"];
    if (!strDate || [strDate length] < 5)
    {
        lblDate.text = @"-";
    }
    else
    {
        IDDateHelper * dh = [IDDateHelper sharedIDDateHelper];
        NSDate * date = [dh mysqlDateTimeToDate:strDate];
        lblDate.text = date ? [dh formatSmartAsDayOrTime:date] : @"-";
    }
}

@end
