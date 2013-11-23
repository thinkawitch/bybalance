//
//  AppSettings.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

//my keys
#define OPT_DICT_SETTINGS   @"Settings"
#define OPT_KEY_BUILD       @"build"
#define OPT_KEY_APN_TOKEN   @"apnToken"

//settings bundle keys
#define SB_OPT_KEY_VERSION      @"version"
#define SB_OPT_KEY_AUTOCHECK    @"check_periodically"

#import "AppSettings.h"

@implementation AppSettings

@synthesize build;
@synthesize apnToken;

SYNTHESIZE_SINGLETON_FOR_CLASS(AppSettings, sharedAppSettings);

#pragma mark - ObjectLife

+ (void) initialize
{	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableDictionary *settingsDefaults = [NSMutableDictionary dictionary];	
	
	NSMutableDictionary *userDefaults = [NSMutableDictionary dictionary];
    [userDefaults setObject:[NSNumber numberWithInt:1] forKey:OPT_KEY_BUILD];
    [userDefaults setObject:@"" forKey:OPT_KEY_APN_TOKEN];
	
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


#pragma mark - Public

- (void) load
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [defaults objectForKey:OPT_DICT_SETTINGS];
    
    self.build = [PRIMITIVE_HELPER numberIntegerValue:[userDefaults objectForKey:OPT_KEY_BUILD]];
    self.apnToken = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:OPT_KEY_APN_TOKEN]];
}

- (void) save
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [NSMutableDictionary dictionary];

    [userDefaults setObject:self.build forKey:OPT_KEY_BUILD];
    [userDefaults setObject:self.apnToken forKey:OPT_KEY_APN_TOKEN];
	
	[defaults setObject:userDefaults forKey:OPT_DICT_SETTINGS];
    [defaults synchronize];
}


@end
