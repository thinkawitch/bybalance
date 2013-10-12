//
//  BBMModelsExtension.h
//  ByBalance
//
//  Created by Admin on 01.05.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBMAccount (ByBalance)

- (NSString *) nameLabel;
- (BBMBalanceHistory *) lastGoodBalance;
+ (NSNumber *) nextOrder;

@end
