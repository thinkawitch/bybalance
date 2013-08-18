//
//  BBMUtils.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBMUtils.h"


@implementation BBMAccount (Utils)

- (BBMBalanceHistory *) lastGoodBalance
{
    if (!self.history) return nil;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"extracted=1 AND account=%@", self];
    return [BBMBalanceHistory findFirstWithPredicate:predicate 
                                            sortedBy:@"date" 
                                           ascending:NO];
    
}

+ (NSNumber *) nextOrder
{
    NSInteger next = 1;
    BBMAccount * last = [BBMAccount findFirstWithPredicate:nil sortedBy:@"order" ascending:NO];
    if (last)
    {
        next = [last.order integerValue] + 1;
    }
    
    return [NSNumber numberWithInt:next];
}

@end
