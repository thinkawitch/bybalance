//
//  BBMBalanceHistory.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/5/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccount;

@interface BBMBalanceHistory : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * balance;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * days;
@property (nonatomic, retain) NSNumber * extracted;
@property (nonatomic, retain) NSNumber * incorrectLogin;
@property (nonatomic, retain) NSDecimalNumber * megabytes;
@property (nonatomic, retain) NSNumber * minutes;
@property (nonatomic, retain) NSNumber * packages;
@property (nonatomic, retain) NSNumber * sms;
@property (nonatomic, retain) NSDecimalNumber * credit;
@property (nonatomic, retain) BBMAccount *account;

@end
