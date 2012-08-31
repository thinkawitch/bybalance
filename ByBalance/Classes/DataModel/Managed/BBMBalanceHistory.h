//
//  BBMBalanceHistory.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccount;

@interface BBMBalanceHistory : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * balance;
@property (nonatomic, retain) NSNumber * isBanned;
@property (nonatomic, retain) NSNumber * isExtracted;
@property (nonatomic, retain) BBMAccount *account;

@end
