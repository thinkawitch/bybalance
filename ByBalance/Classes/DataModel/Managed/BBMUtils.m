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
    
    switch (type)
    {
        case kAccountMts:
            item = [BBItemMts new];
            break;
            
        case kAccountBn:
            item = [BBItemBn new];
            break;
            
        case kAccountVelcom:
            item = [BBItemVelcom new];
            break;
            
        case kAccountLife:
            item = [BBItemLife new];
            break;
    }

    if (!item)
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
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"extracted=1 AND account=%@", self];
    return [BBMBalanceHistory findFirstWithPredicate:predicate 
                                            sortedBy:@"date" 
                                           ascending:NO];
    
}

@end
