//
//  BBMAccount.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccountType, BBMBalanceHistory;

@interface BBMAccount : NSManagedObject

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) BBMAccountType *type;
@property (nonatomic, retain) NSSet *history;
@end

@interface BBMAccount (CoreDataGeneratedAccessors)

- (void)addHistoryObject:(BBMBalanceHistory *)value;
- (void)removeHistoryObject:(BBMBalanceHistory *)value;
- (void)addHistory:(NSSet *)values;
- (void)removeHistory:(NSSet *)values;

@end
