//
//  BBMBalanceHistory.h
//  ByBalance2
//
//  Created by Andrew Sinkevitch on 10/12/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccount;

@interface BBMBalanceHistory : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * balance;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * extracted;
@property (nonatomic, retain) NSNumber * incorrectLogin;
@property (nonatomic, retain) BBMAccount *account;

@end
