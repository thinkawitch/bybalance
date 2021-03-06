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

}

@property (nonatomic, strong) NSNumber * build;
@property (nonatomic, strong) NSString * apnToken;
@property (nonatomic, strong) NSString * basesVersion;
@property (nonatomic, assign) NSInteger basesChecked;

+ (AppSettings *) sharedAppSettings;

- (void) load;
- (void) save;

@end
