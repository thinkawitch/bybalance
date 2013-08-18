//
//  BBMUtils.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//


@interface BBMAccount (Utils)

- (BBMBalanceHistory *) lastGoodBalance;
+ (NSNumber *) nextOrder;

@end
