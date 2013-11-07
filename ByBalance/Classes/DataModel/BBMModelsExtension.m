//
//  BBMModelsExtension.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01.05.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBMModelsExtension.h"

@implementation BBMAccount (ByBalance)

- (NSString *) nameLabel
{
    if ([self.label length] > 0) return [NSString stringWithString:self.label];
    return [NSString stringWithString:self.username];
}

- (BBMBalanceHistory *) lastBalance
{
    if (!self.history) return nil;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"account=%@", self];
    return [BBMBalanceHistory findFirstWithPredicate:predicate
                                            sortedBy:@"date"
                                           ascending:NO];
}

- (BBMBalanceHistory *) lastGoodBalance
{
    if (!self.history) return nil;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"extracted=1 AND account=%@", self];
    return [BBMBalanceHistory findFirstWithPredicate:predicate
                                            sortedBy:@"date"
                                           ascending:NO];
}

- (NSString *) lastGoodBalanceDate
{
    BBMBalanceHistory * bh = [self lastGoodBalance];
    if (!bh) return @"";
    
    return [DATE_HELPER formatSmartAsDayOrTime:bh.date];
}

- (NSString *) lastGoodBalanceValue
{
    BBMBalanceHistory * bh = [self lastGoodBalance];
    if (!bh) return @"не обновлялся";
    
    if ([self.type.id intValue] == kAccountAnitex)
    {
        if ([bh.balance floatValue] != 0.0f)
        {
            return [NSNumberFormatter localizedStringFromNumber:bh.balance numberStyle:NSNumberFormatterDecimalStyle];
        }
        else
        {
            return[NSNumberFormatter localizedStringFromNumber:bh.megabytes numberStyle:NSNumberFormatterDecimalStyle];
        }
    }
    else
    {
        return [NSNumberFormatter localizedStringFromNumber:bh.balance numberStyle:NSNumberFormatterDecimalStyle];
    }
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
