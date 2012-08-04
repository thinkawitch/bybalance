//
//  AppSettings.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject
{
    
@private
    NSNumber * userId;
    NSString * authToken;
    NSString * username;
    NSString * email;
    NSString * password;
    BOOL sendEmailUpdates;
    NSNumber * introVersion;
    
    NSString * log;
}

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, assign) BOOL sendEmailUpdates;
@property (nonatomic, retain) NSNumber * introVersion;
@property (nonatomic, retain) NSString * log;

+ (AppSettings *) sharedAppSettings;

- (void) loadData;
- (void) saveData;
- (BOOL) isLoggedIn;
- (void) logout;

@end
