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
    lblDate.text = [dict objectForKey:@"date"];
    
}

@end
