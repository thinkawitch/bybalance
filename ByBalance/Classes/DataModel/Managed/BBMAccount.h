//
//  BBMAccount.h
//  ByBalance
//
//  Created by Admin on 06/10/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccountType, BBMBalanceHistory;

@interface BBMAccount : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *history;
@property (nonatomic, retain) BBMAccountType *type;
@end

@interface BBMAccount (CoreDataGeneratedAccessors)

- (void)addHistoryObject:(BBMBalanceHistory *)value;
- (void)removeHistoryObject:(BBMBalanceHistory *)value;
- (void)addHistory:(NSSet *)values;
- (void)removeHistory:(NSSet *)values;

@end
