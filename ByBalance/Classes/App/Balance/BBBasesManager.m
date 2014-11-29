//
//  BBBasesManager.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 29/11/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//

#import "BBBasesManager.h"

@interface BBBasesManager ()

@property (strong,nonatomic) NSString *updateMessage;

- (NSString *) basesFilepath;
- (BOOL) saveBases:(NSString *)bases;

@end


@implementation BBBasesManager

SYNTHESIZE_SINGLETON_FOR_CLASS(BBBasesManager, sharedBBBasesManager);

- (void) updateWithCallback:(void(^)(BOOL,NSString*))callback
{
    NSString *url = [NSString stringWithFormat:@"%@", kBasesServerUrl];
    AFHTTPRequestOperationManager * httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    [httpClient.requestSerializer setValue:kBrowserUserAgent forHTTPHeaderField:@"User-Agent"];
    httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    httpClient.securityPolicy.allowInvalidCertificates = YES;
    
    [httpClient GET:@"bases.js" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * bases = [NSString stringWithFormat:@"%@", operation.responseString];
        BOOL saved = [self saveBases:bases];
        
        if (callback) callback(saved, self.updateMessage);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        
        if (callback) callback(NO, [NSString stringWithFormat:@"Ошибка сервера: %@", error.localizedDescription]);
    }];
}


#pragma mark - Private

- (NSString *) basesFilepath
{
    NSString *filePath = [APP_CONTEXT.basePath stringByAppendingPathComponent:@"bases.js"];
    DDLogVerbose(@"%@", filePath);
    return filePath;
}

- (BOOL) saveBases:(NSString *)bases
{
    DDLogVerbose(@"bases %@", bases);
    if ([bases length] < 10)
    {
        self.updateMessage = @"Ошибка чтения файла баз";
        return NO;
    }
    
    JSContext *context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    [context evaluateScript:bases];
    NSString *newVersion = [context[@"bb"][@"version"] toString];
    if ([newVersion length] < 6 || [newVersion isEqualToString:@"undefined"])
    {
        self.updateMessage = @"Версия баз неправильная";
        return NO;
    }
    
    NSString *currVersion = SETTINGS.basesVersion;
    
    BOOL needUpdate = ([newVersion compare:currVersion options:NSNumericSearch] == NSOrderedDescending);
    if (!needUpdate)
    {
        self.updateMessage = @"У вас самая последняя версия баз";
        return NO;
    }
    
    DDLogVerbose(@"bases new version: %@", newVersion);
    
    NSString *path = [self basesFilepath];
    BOOL saved = [bases writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (saved)
    {
        
        SETTINGS.basesVersion = newVersion;
        [SETTINGS save];
        self.updateMessage = @"Базы обновлены";
    }
    else
    {
        self.updateMessage = @"Ошибка сохранения файла баз";
    }
    
    return saved;
}

@end
