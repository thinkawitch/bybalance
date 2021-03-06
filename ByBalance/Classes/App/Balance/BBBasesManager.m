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
    UIWebView * webView;
    JSContext * jsContext;
    BOOL basesReady;
    BOOL isBusy;
    NSString * updateMessage;
    AFHTTPRequestOperationManager * httpClient;
}

- (NSString *) basesFilepath;
- (BOOL) saveBases:(NSString *)bases;
- (BOOL) checkBasesVersion:(NSString *)verions;
- (void) prepareJsContext;

@end


@implementation BBBasesManager

//@synthesize webView, jsContext;
SYNTHESIZE_SINGLETON_FOR_CLASS(BBBasesManager, sharedBBBasesManager);

- (void) start
{

    //dispatch_async(dispatch_get_main_queue(), ^(void){
        webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        //DDLogVerbose(@"jsContext1 %@", jsContext);
    //});
    //DDLogVerbose(@"jsContext2 %@", jsContext);
    //jsContext = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    NSString * bases = [NSString stringWithContentsOfFile:[self basesFilepath] encoding:NSUTF8StringEncoding error:nil];
    if ([bases length])
    {
        [self prepareJsContext];
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

- (void) prepareJsContext
{
    [jsContext setExceptionHandler:^(JSContext *context, JSValue *value) {
        DDLogError(@"js_exception: %@", value);
    }];
    
    #ifdef DEBUG
    jsContext[@"bbLog"] = ^{
        NSArray * args = [JSContext currentArguments];
        DDLogVerbose(@"js_console: %@", [args componentsJoinedByString:@" | "]);
    };
    #endif
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
    if (webView) webView = nil;
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
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithUnsignedInteger:arc4random()], @"r",
                             nil];
    
    [httpClient GET:@"bases.js" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithUnsignedInteger:arc4random()], @"r",
                             nil];
    
    [httpClient GET:@"bases.js" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    //DDLogVerbose(@"BasesManager - bases %@", bases);
    
    if ([bases length] < 10)
    {
        updateMessage = @"Ошибка чтения файла баз";
        return NO;
    }
    
    //JSContext * context = [[[UIWebView alloc] initWithFrame:CGRectZero] valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSContext * context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        DDLogVerbose(@"js_exception_2: %@", value);
    }];
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
        [self prepareJsContext];
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


- (BBLoaderInfo *) extractInfoForType:(NSInteger)type fromHtml:(NSString *)html
{
    BBLoaderInfo * info = [BBLoaderInfo new];
    
    JSValue * func = jsContext[@"extractData"];
    NSArray * args = @[[NSNumber numberWithInteger:type],[NSString stringWithFormat:@"%@", html]];
    JSValue * result = [func callWithArguments:args];
    
    BOOL notSupported = [result[@"notSupported"] toBool];
    BOOL extracted = [result[@"extracted"] toBool];
    BOOL incorrectLogin = [result[@"incorrectLogin"] toBool];
    NSNumber * balance = [result[@"balance"] toNumber];
    NSString * bonuses = [result[@"bonuses"] toString];
    
    DDLogVerbose(@"converted result");
    DDLogVerbose(@"notSupported: %d, extracted: %d, incorrectLogin: %d, balance: %@, bonuses: %@", notSupported, extracted, incorrectLogin, balance, bonuses);
    
    info.extracted = extracted;
    info.incorrectLogin = incorrectLogin;
    if (extracted)
    {
        info.userBalance = [NSDecimalNumber decimalNumberWithDecimal:[balance decimalValue]];
        info.bonuses = bonuses;
    }
    
    return info;
}

- (void) putUsername:(NSString *)username
{
    jsContext[@"username"] = username;
}

@end
