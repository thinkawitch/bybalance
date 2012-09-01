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
        //item = [BBItemBN new];
    }
    else
    {
        return nil;
    }
    
    item.username = self.username;
    item.password = self.password;
    
    return item;
}

@end
