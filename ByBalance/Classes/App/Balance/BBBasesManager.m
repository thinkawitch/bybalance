//
//  BBBasesManager.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 29/11/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//

#import "BBBasesManager.h"

@interface BBBasesManager ()
{
    JSContext * jsContext;
    BOOL basesReady;
    BOOL isBusy;
    NSString * updateMessage;
    AFHTTPRequestOperationManager * httpClient;
}

- (NSString *) basesFilepath;
- (BOOL) saveBases:(NSString *)bases;
- (BOOL) checkBasesVersion:(NSString *)verions;

@end


@implementation BBBasesManager

SYNTHESIZE_SINGLETON_FOR_CLASS(BBBasesManager, sharedBBBasesManager);

- (void) start
{
    jsContext = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    NSString * bases = [NSString stringWithContentsOfFile:[self basesFilepath] encoding:NSUTF8StringEncoding error:nil];
    if ([bases length])
    {
        [jsContext evaluateScript:bases];
        NSString * version = [jsContext[@"bb"][@"version"] toString];
        basesReady = [self checkBasesVersion:version];
    }
    
    NSString * url = [NSString stringWithFormat:@"%@", kBasesServerUrl];
    httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    [httpClient.requestSerializer setValue:kBrowserUserAgent forHTTPHeaderField:@"User-Agent"];
    httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    httpClient.securityPolicy.allowInvalidCertificates = YES;
}

- (BOOL) isReady
{
    return basesReady;
}

- (BOOL) isBusy
{
    return isBusy;
}

- (void) stop
{
    basesReady = NO;
    if (jsContext) jsContext = nil;
    if (httpClient) httpClient = nil;
}

- (void) checkForUpdate
{
    NSInteger now = [[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] integerValue];
    if (now - SETTINGS.basesChecked < 86400) {
        DDLogVerbose(@"BasesManager - bases checked today already");
        return;
    }
    
    DDLogVerbose(@"BasesManager - try to update");
    isBusy = YES;
    
    [httpClient GET:@"bases.js" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * bases = [NSString stringWithFormat:@"%@", operation.responseString];
        [self saveBases:bases];
        
        isBusy = NO;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        isBusy = NO;
    }];
}

- (void) updateBasesWithCallback:(void(^)(BOOL,NSString*))callback
{
    isBusy = YES;
    
    [httpClient GET:@"bases.js" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * bases = [NSString stringWithFormat:@"%@", operation.responseString];
        BOOL saved = [self saveBases:bases];
        isBusy = NO;
        if (callback) callback(saved, updateMessage);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        isBusy = NO;
        if (callback) callback(NO, [NSString stringWithFormat:@"Ошибка сервера: %@", error.localizedDescription]);
    }];
}


#pragma mark - Private

- (NSString *) basesFilepath
{
    NSString * filePath = [APP_CONTEXT.basePath stringByAppendingPathComponent:@"bases.js"];
    //DDLogVerbose(@"%@", filePath);
    return filePath;
}

- (BOOL) saveBases:(NSString *)bases
{
    DDLogVerbose(@"BasesManager - bases %@", bases);
    
    if ([bases length] < 10)
    {
        updateMessage = @"Ошибка чтения файла баз";
        return NO;
    }
    
    JSContext * context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    [context evaluateScript:bases];
    NSString * newVersion = [context[@"bb"][@"version"] toString];
    if (![self checkBasesVersion:newVersion])
    {
        updateMessage = @"Версия баз неправильная";
        return NO;
    }
    
    SETTINGS.basesChecked = [[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] integerValue];
    [SETTINGS save];
    
    BOOL needUpdate = ([newVersion compare:SETTINGS.basesVersion options:NSNumericSearch] == NSOrderedDescending);
    if (!needUpdate)
    {
        updateMessage = @"У вас самая последняя версия баз";
        return NO;
    }
    
    DDLogVerbose(@"BasesManager - bases new version: %@", newVersion);
    
    NSString * path = [self basesFilepath];
    BOOL saved = [bases writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (saved)
    {
        SETTINGS.basesVersion = newVersion;
        [SETTINGS save];
        updateMessage = @"Базы обновлены";
        [jsContext evaluateScript:bases]; //insert into context
    }
    else
    {
        updateMessage = @"Ошибка сохранения файла баз";
    }
    
    return saved;
}

- (BOOL) checkBasesVersion:(NSString *)verion;
{
    return ([verion length] >= 6 && ![verion isEqualToString:@"undefined"]);
}

@end
