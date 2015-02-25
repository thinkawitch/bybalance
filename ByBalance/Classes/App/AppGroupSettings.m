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

@implementation AppGroupSettings

@synthesize accounts;

SYNTHESIZE_SINGLETON_FOR_CLASS(AppGroupSettings, sharedAppGroupSettings);

#pragma mark - ObjectLife

+ (void) initialize
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kAgsNamespace];
    NSMutableDictionary *settingsDefaults = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *userDefaults = [NSMutableDictionary dictionary];
    [userDefaults setObject:[NSArray array] forKey:kAgsAccounts];
    
    [settingsDefaults setObject:userDefaults forKey:kAgsSettings];
    
    [defaults registerDefaults:settingsDefaults];
    [defaults synchronize];
}

#pragma mark - Public

- (void) load
{
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:kAgsNamespace];
    
    NSMutableDictionary * userDefaults = [defaults objectForKey:kAgsSettings];
    
    self.accounts = [userDefaults objectForKey:kAgsAccounts];
}

- (void) save
{
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:kAgsNamespace];
    
    NSMutableDictionary * userDefaults = [NSMutableDictionary dictionary];
    
    [userDefaults setObject:self.accounts forKey:kAgsAccounts];
    
    [defaults setObject:userDefaults forKey:kAgsSettings];
    [defaults synchronize];
}

@end
