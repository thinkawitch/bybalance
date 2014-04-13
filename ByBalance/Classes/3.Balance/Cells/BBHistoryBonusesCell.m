//
//  BBHistoryBonusesCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 4/13/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//

#import "BBHistoryBonusesCell.h"

@implementation BBHistoryBonusesCell

- (void) setupWithHistory:(BBMBalanceHistory *) history
{
    [super setupWithHistory:history];
    
    lblBonuses.text = [NSString stringWithFormat:@"%@", history.bonuses];
}

@end
