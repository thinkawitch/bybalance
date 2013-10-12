//
//  AppSettings.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

//my keys
#define OPT_DICT_SETTINGS   @"Settings"
#define OPT_KEY_APP_ID      @"appId"
#define OPT_KEY_BUILD       @"build"

//settings bundle keys
#define SB_OPT_KEY_VERSION      @"version"
#define SB_OPT_KEY_AUTOCHECK    @"check_periodically"

#import "AppSettings.h"

@implementation AppSettings

@synthesize appId;
@synthesize build;
@synthesize autoCheck;

SYNTHESIZE_SINGLETON_FOR_CLASS(AppSettings, sharedAppSettings);

#pragma mark - ObjectLife

+ (void) initialize
{	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableDictionary *settingsDefaults = [NSMutableDictionary dictionary];	
	
	NSMutableDictionary *userDefaults = [NSMutableDictionary dictionary];
    [userDefaults setObject:@"" forKey:OPT_KEY_APP_ID];
    [userDefaults setObject:[NSNumber numberWithInt:1] forKey:OPT_KEY_BUILD];
	
	[settingsDefaults setObject:userDefaults forKey:OPT_DICT_SETTINGS];
	
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


- (void) dealloc
{
    self.appId = nil;
    self.build = nil;
	
	[super dealloc];
}

#pragma mark - Public

- (void) loadData
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [defaults objectForKey:OPT_DICT_SETTINGS];
    
    self.appId = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:OPT_KEY_APP_ID]];
    self.build = [PRIMITIVE_HELPER numberIntegerValue:[userDefaults objectForKey:OPT_KEY_BUILD]];
    self.autoCheck = [defaults boolForKey:SB_OPT_KEY_AUTOCHECK];
}

- (void) saveData
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [NSMutableDictionary dictionary];

    [userDefaults setObject:appId?appId:@"" forKey:OPT_KEY_APP_ID];
    [userDefaults setObject:build?build:@"" forKey:OPT_KEY_BUILD];
	
	[defaults setObject:userDefaults forKey:OPT_DICT_SETTINGS];
    [defaults synchronize];
}


@end
