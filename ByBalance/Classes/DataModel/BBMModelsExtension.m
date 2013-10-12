//
//  BBMModelsExtension.m
//  ByBalance
//
//  Created by Admin on 01.05.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBMModelsExtension.h"

@implementation BBMAccount (ByBalance)

- (NSString *) nameLabel
{
    if ([self.label length] > 0) return [NSString stringWithString:self.label];
    return [NSString stringWithString:self.username];
}

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
