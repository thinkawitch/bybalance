//
//  BBMUtils.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBMUtils.h"


@implementation BBMAccount (Utils)

- (BBBaseItem *) basicItem
{
    BBBaseItem * item = nil;
    NSInteger type = [self.type.id integerValue];

    if (type == kAccountMTS)
    {
        item = [BBItemMts new];
    }
    else if (type == kAccountBN)
    {
        item = [BBItemBn new];
    }
    else if (type == kAccountVelcom)
    {
        item = [BBItemVelcom new];
    }
    else
    {
        return nil;
    }
    
    item.username = self.username;
    item.password = self.password;
    
    return [item autorelease];
}

- (BBMBalanceHistory *) lastGoodBalance
{
    if (!self.history) return nil;
    
    /*
    [BBMBalanceHistory findByAttribute:@"account" 
                             withValue:self 
                            andOrderBy:@"date" 
                             ascending:NO];
    */
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isExtracted=1 AND account=%@", self];
    return [BBMBalanceHistory findFirstWithPredicate:predicate 
                                            sortedBy:@"date" 
                                           ascending:NO];
    
}

@end
