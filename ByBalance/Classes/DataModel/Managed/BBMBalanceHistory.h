//
//  BBMBalanceHistory.h
//  ByBalance
//
//  Created by Admin on 06/10/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccount;

@interface BBMBalanceHistory : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * balance;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * incorrectLogin;
@property (nonatomic, retain) NSNumber * extracted;
@property (nonatomic, retain) BBMAccount *account;

@end
