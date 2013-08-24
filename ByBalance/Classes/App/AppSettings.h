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
    NSString * appId;
    NSNumber * build;
    BOOL autoCheck;
}

@property (nonatomic, retain) NSString * appId;
@property (nonatomic, retain) NSNumber * build;
@property (nonatomic, assign) BOOL autoCheck;

+ (AppSettings *) sharedAppSettings;

- (void) loadData;
- (void) saveData;

@end
