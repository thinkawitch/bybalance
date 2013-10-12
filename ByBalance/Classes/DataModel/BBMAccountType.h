//
//  BBMAccountType.h
//  ByBalance
//
//  Created by Admin on 06/10/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccount;

@interface BBMAccountType : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *accounts;
@end

@interface BBMAccountType (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(BBMAccount *)value;
- (void)removeAccountsObject:(BBMAccount *)value;
- (void)addAccounts:(NSSet *)values;
- (void)removeAccounts:(NSSet *)values;

@end
