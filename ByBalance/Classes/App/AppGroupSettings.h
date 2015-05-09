//
//  AppGroupSettings.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 25.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppGroupSettings : NSObject
{
    
}

@property (nonatomic, strong) NSArray * accounts;
@property (nonatomic, assign) NSInteger updateBegin;
@property (nonatomic, assign) NSInteger updateEnd;

+ (AppGroupSettings *) sharedAppGroupSettings;

- (void) load;
- (void) save;

@end
