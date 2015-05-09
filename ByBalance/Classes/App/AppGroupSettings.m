//
//  AppGroupSettings.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 25.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "AppGroupSettings.h"
#import "IDPrimitiveHelper.h"

//my keys
NSString * const kAgsNamespace = @"group.name.sinkevitch.ByBalance";
NSString * const kAgsSettings = @"GroupSettings";
NSString * const kAgsAccounts = @"accounts";
NSString * const kAgsUpdateBegin = @"updateBegin";
NSString * const kAgsUpdateEnd = @"updateEnd";

@implementation AppGroupSettings

@synthesize accounts;
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
    IDPrimitiveHelper * ph = [IDPrimitiveHelper sharedIDPrimitiveHelper];
    self.updateBegin = [ph integerValue:[settings objectForKey:kAgsUpdateBegin]];
    self.updateEnd = [ph integerValue:[settings objectForKey:kAgsUpdateEnd]];
}

- (void) save
{
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:kAgsNamespace];
    
    NSMutableDictionary * settings = [NSMutableDictionary dictionary];
    
    [settings setObject:self.accounts forKey:kAgsAccounts];
    [settings setObject:[NSNumber numberWithInteger:self.updateBegin] forKey:kAgsUpdateBegin];
    [settings setObject:[NSNumber numberWithInteger:self.updateEnd] forKey:kAgsUpdateEnd];
    
    [defaults setObject:settings forKey:kAgsSettings];
    [defaults synchronize];
}

@end
