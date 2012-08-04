//
//  BBMAccountType.h
//  ByBalance
//
//  Created by Lion User on 04/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BBMAccountType : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *accounts;
@end

@interface BBMAccountType (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(NSManagedObject *)value;
- (void)removeAccountsObject:(NSManagedObject *)value;
- (void)addAccounts:(NSSet *)values;
- (void)removeAccounts:(NSSet *)values;

@end
