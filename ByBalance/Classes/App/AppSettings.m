//
//  AppSettings.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "AppSettings.h"

//my keys
NSString * const kAsSettings = @"Settings";
NSString * const kAsKeyBuild = @"build";
NSString * const kAsKeyApnToken = @"apnToken";
NSString * const kAsKeyBasesVersion = @"basesVersion";
NSString * const kAsKeyBasesChecked = @"basesChecked";

@implementation AppSettings

@synthesize build;
@synthesize apnToken;
@synthesize basesVersion;
@synthesize basesChecked;

SYNTHESIZE_SINGLETON_FOR_CLASS(AppSettings, sharedAppSettings);

#pragma mark - ObjectLife

+ (void) initialize
{	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableDictionary *settingsDefaults = [NSMutableDictionary dictionary];	
	
	NSMutableDictionary *userDefaults = [NSMutableDictionary dictionary];
    [userDefaults setObject:@1 forKey:kAsKeyBuild];
    [userDefaults setObject:@"" forKey:kAsKeyApnToken];
    [userDefaults setObject:@"" forKey:kAsKeyBasesVersion];
    [userDefaults setObject:@1 forKey:kAsKeyBasesChecked];
	
	[settingsDefaults setObject:userDefaults forKey:kAsSettings];
	
    [defaults registerDefaults:settingsDefaults];
    [defaults synchronize];
}

- (id) init
{
	self = [super init];
	if (self)
	{
		//
	}
	
	return self;
}


#pragma mark - Public

- (void) load
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [defaults objectForKey:kAsSettings];
    
    self.build = [PRIMITIVE_HELPER numberIntegerValue:[userDefaults objectForKey:kAsKeyBuild]];
    self.apnToken = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:kAsKeyApnToken]];
    self.basesVersion = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:kAsKeyBasesVersion]];
    self.basesChecked = [PRIMITIVE_HELPER integerValue:[userDefaults objectForKey:kAsKeyBasesChecked]];
}

- (void) save
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [NSMutableDictionary dictionary];

    [userDefaults setObject:self.build forKey:kAsKeyBuild];
    [userDefaults setObject:self.apnToken forKey:kAsKeyApnToken];
    [userDefaults setObject:self.basesVersion forKey:kAsKeyBasesVersion];
    [userDefaults setObject:[NSNumber numberWithInteger:self.basesChecked] forKey:kAsKeyBasesChecked];
	
	[defaults setObject:userDefaults forKey:kAsSettings];
    [defaults synchronize];
}


@end
