//
//  BBBalanceInfo.h
//  ByBalance
//
//  Created by Admin on 18.08.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBLoaderInfo : NSObject
{
    
}

@property (nonatomic,assign) BOOL incorrectLogin;
@property (nonatomic,assign) BOOL extracted;
@property (nonatomic,retain) NSString * userTitle;
@property (nonatomic,retain) NSString * userPlan;
@property (nonatomic,retain) NSString * userBalance;

- (NSString *) fullDescription;

@end
