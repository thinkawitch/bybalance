//
//  AppSettings.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define OPT_DICT_SETTINGS   @"Settings"
#define OPT_KEY_USER_ID     @"user_id"
#define OPT_KEY_AUTH_TOKEN  @"auth_token"
#define OPT_KEY_USERNAME    @"username"
#define OPT_KEY_EMAIL       @"email"
#define OPT_KEY_PASSWORD    @"password"
#define OPT_KEY_SEND_EMAIL_UPDATES  @"sendEmailUpdates"
#define OPT_KEY_INTRO_VERSION  @"introVersion"
#define OPT_KEY_LOG  @"log"

#import "AppSettings.h"

@implementation AppSettings

@synthesize userId;
@synthesize authToken;
@synthesize username;
@synthesize email;
@synthesize password;
@synthesize sendEmailUpdates;
@synthesize introVersion;
@synthesize log;

SYNTHESIZE_SINGLETON_FOR_CLASS(AppSettings);

#pragma mark - ObjectLife

+ (void) initialize
{	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableDictionary *settingsDefaults = [NSMutableDictionary dictionary];	
	
	NSMutableDictionary *userDefaults = [NSMutableDictionary dictionary];
    [userDefaults setObject:@"" forKey:OPT_KEY_USER_ID];
    [userDefaults setObject:@"" forKey:OPT_KEY_AUTH_TOKEN];
	[userDefaults setObject:@"" forKey:OPT_KEY_USERNAME];
    [userDefaults setObject:@"" forKey:OPT_KEY_EMAIL];
	[userDefaults setObject:@"" forKey:OPT_KEY_PASSWORD];
	[userDefaults setObject:[NSNumber numberWithBool:NO] forKey:OPT_KEY_SEND_EMAIL_UPDATES];
    [userDefaults setObject:[NSNumber numberWithInt:1] forKey:OPT_KEY_INTRO_VERSION];
	
	[settingsDefaults setObject:userDefaults forKey:OPT_DICT_SETTINGS]; 
    
    [userDefaults setObject:@"" forKey:OPT_KEY_LOG];
	
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
    self.userId = nil;
    self.authToken = nil;
	self.username = nil;
    self.email = nil;
	self.password = nil;
    self.introVersion = nil;
    self.log = nil;
	
	[super dealloc];
}

#pragma mark - Public

- (void) loadData
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [defaults objectForKey:OPT_DICT_SETTINGS];
    
    self.userId = [PRIMITIVE_HELPER numberIntegerValue:[userDefaults objectForKey:OPT_KEY_USER_ID]];
    self.authToken = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:OPT_KEY_AUTH_TOKEN]];
	self.username = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:OPT_KEY_USERNAME]];
	self.email = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:OPT_KEY_EMAIL]];
    self.password = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:OPT_KEY_PASSWORD]];
	self.sendEmailUpdates = [[PRIMITIVE_HELPER numberIntegerValue:[userDefaults objectForKey:OPT_KEY_SEND_EMAIL_UPDATES]] boolValue];	
    
    self.introVersion = [PRIMITIVE_HELPER numberIntegerValue:[userDefaults objectForKey:OPT_KEY_INTRO_VERSION]];
    if ([self.introVersion intValue] < 1) 
    {
        self.introVersion = [NSNumber numberWithInt:1];
    }
    
    self.log = [PRIMITIVE_HELPER stringValue:[userDefaults objectForKey:OPT_KEY_LOG]];
}

- (void) saveData
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
	
	NSMutableDictionary * userDefaults = [NSMutableDictionary dictionary];
	
    [userDefaults setObject:userId?userId:0 forKey:OPT_KEY_USER_ID];
    [userDefaults setObject:authToken?authToken:@"" forKey:OPT_KEY_AUTH_TOKEN];
	[userDefaults setObject:username?username:@"" forKey:OPT_KEY_USERNAME];
    [userDefaults setObject:email?email:@"" forKey:OPT_KEY_EMAIL];
	[userDefaults setObject:password?password:@"" forKey:OPT_KEY_PASSWORD];
	[userDefaults setObject:[NSNumber numberWithBool:sendEmailUpdates] forKey:OPT_KEY_SEND_EMAIL_UPDATES];
    
    [userDefaults setObject:introVersion?introVersion:[NSNumber numberWithInt:1] forKey:OPT_KEY_INTRO_VERSION];
    
    [userDefaults setObject:log?log:@"" forKey:OPT_KEY_LOG];
	
	[defaults setObject:userDefaults forKey:OPT_DICT_SETTINGS];
    [defaults synchronize];
}

- (BOOL) isLoggedIn
{
    if (!self.userId || [self.userId intValue] < 1) return NO;
    if (!self.authToken || [self.authToken length] < 1) return NO;
    
    return YES;
}

- (void) logout
{
    self.userId = [NSNumber numberWithInt:0];
    self.authToken = @"";
    self.username = @"";
    self.email = @"";
    self.password = @"";
}

@end
