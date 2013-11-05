//
//  BBBalanceInfo.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 18.08.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBLoaderInfo : NSObject
{
    
}

@property (nonatomic,assign) BOOL incorrectLogin;
@property (nonatomic,assign) BOOL extracted;

@property (nonatomic,strong) NSString * userTitle;
@property (nonatomic,strong) NSString * userPlan;

@property (nonatomic,strong) NSDecimalNumber * userBalance;

@property (nonatomic,strong) NSNumber * userMegabytes;
@property (nonatomic,strong) NSNumber * userMinutes;
@property (nonatomic,strong) NSNumber * userSms;

@property (nonatomic,strong) NSNumber * userPackages;
@property (nonatomic,strong) NSNumber * userDays;

- (NSString *) fullDescription;

@end
