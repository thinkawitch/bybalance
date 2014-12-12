//
//  BBLoaderNetBerry.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 21.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderNetBerry.h"

@interface BBLoaderNetBerry ()

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end


@implementation BBLoaderNetBerry

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://user.nbr.by/"];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"0", @"midAuth",
                             self.account.username, @"user",
                             self.account.password, @"pswd",
                             nil];
    
    [self.httpClient POST:@"/bgbilling/webexecuter" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderNetBerry.onStep1");
    //DDLogVerbose(@"%@", html);
    
    //Ошибка при авторизации
    if ([html rangeOfString:@"Ошибка при авторизации"].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    //ссылка на страницу баланса
    if ([html rangeOfString:@"?action=ShowBalance&mid=contract"].location == NSNotFound)
    {
        [self doFinish];
        return;
    }
    
    //https://user.nbr.by/bgbilling/webexecuter?action=ShowBalance&mid=contract

    [self.httpClient GET:@"/bgbilling/webexecuter?action=ShowBalance&mid=contract" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
    
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderNetBerry.onStep2");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

@end
