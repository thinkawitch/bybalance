//
//  BBMBalanceHistory.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 4/13/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccount;

@interface BBMBalanceHistory : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * balance;
@property (nonatomic, retain) NSDecimalNumber * credit;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * days;
@property (nonatomic, retain) NSNumber * extracted;
@property (nonatomic, retain) NSNumber * incorrectLogin;
@property (nonatomic, retain) NSDecimalNumber * megabytes;
@property (nonatomic, retain) NSNumber * minutes;
@property (nonatomic, retain) NSNumber * packages;
@property (nonatomic, retain) NSNumber * sms;
@property (nonatomic, retain) NSString * bonuses;
@property (nonatomic, retain) BBMAccount *account;

@end
