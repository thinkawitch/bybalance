//
//  BBMAccount.h
//  ByBalance
//
//  Created by Lion User on 04/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBMAccountType;

@interface BBMAccount : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) BBMAccountType *type;

@end
