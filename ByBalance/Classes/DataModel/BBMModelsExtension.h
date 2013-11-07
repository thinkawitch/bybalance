//
//  BBMModelsExtension.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01.05.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBMAccount (ByBalance)

- (NSString *) nameLabel;
- (BBMBalanceHistory *) lastBalance;
- (BBMBalanceHistory *) lastGoodBalance;
- (NSString *) lastGoodBalanceDate;
- (NSString *) lastGoodBalanceValue;
+ (NSNumber *) nextOrder;

@end
