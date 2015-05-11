//
//  AppGroupSettings.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 25.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "AppGroupSettings.h"

//my keys
NSString * const kAgsNamespace = @"group.name.sinkevitch.ByBalance";
NSString * const kAgsSettings = @"GroupSettings";
NSString * const kAgsAccounts = @"accounts";
NSString * const kAgsKeyApnToken = @"apnToken";
NSString * const kAgsUpdateBegin = @"updateBegin";
NSString * const kAgsUpdateEnd = @"updateEnd";


@implementation AppGroupSettings

@synthesize accounts;
@synthesize apnToken;
@synthesize updateBegin, updateEnd;

SYNTHESIZE_SINGLETON_FOR_CLASS(AppGroupSettings, sharedAppGroupSettings);

#pragma mark - ObjectLife

+ (void) initialize
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kAgsNamespace];
    NSMutableDictionary *settingsDefaults = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *userDefaults = [NSMutableDictionary dictionary];
    [userDefaults setObject:[NSArray array] forKey:kAgsAccounts];
    
    [userDefaults setObject:@0 forKey:kAgsUpdateBegin];
    [userDefaults setObject:@0 forKey:kAgsUpdateEnd];
    [userDefaults setObject:@"" forKey:kAgsUpdateBegin];
    
    [settingsDefaults setObject:userDefaults forKey:kAgsSettings];
    
    [defaults registerDefaults:settingsDefaults];
    [defaults synchronize];
}

#pragma mark - Public

- (void) load
{
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:kAgsNamespace];
    
    NSMutableDictionary * settings = [defaults objectForKey:kAgsSettings];
    
    self.accounts = [settings objectForKey:kAgsAccounts];
    self.updateBegin = [PRIMITIVE_HELPER integerValue:[settings objectForKey:kAgsUpdateBegin]];
    self.updateEnd = [PRIMITIVE_HELPER integerValue:[settings objectForKey:kAgsUpdateEnd]];
    self.apnToken = [PRIMITIVE_HELPER stringValue:[settings objectForKey:kAgsKeyApnToken]];
}

- (void) save
{
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:kAgsNamespace];
    
    NSMutableDictionary * settings = [NSMutableDictionary dictionary];
    
    [settings setObject:self.accounts forKey:kAgsAccounts];
    [settings setObject:self.apnToken forKey:kAgsKeyApnToken];
    [settings setObject:[NSNumber numberWithInteger:self.updateBegin] forKey:kAgsUpdateBegin];
    [settings setObject:[NSNumber numberWithInteger:self.updateEnd] forKey:kAgsUpdateEnd];
    
    [defaults setObject:settings forKey:kAgsSettings];
    [defaults synchronize];
}

@end
