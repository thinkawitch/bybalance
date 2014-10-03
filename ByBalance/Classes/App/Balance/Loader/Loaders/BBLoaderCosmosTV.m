//
//  BBLoaderCosmosTV.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 23.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderCosmosTV.h"

@interface BBLoaderCosmosTV ()

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

@end


@implementation BBLoaderCosmosTV

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"http://cosmostv.by/"];
    
    //[self.httpClient setDefaultHeader:@"Referer" value:@"http://cosmostv.by/"];
    [self.httpClient.requestSerializer setValue:@"http://cosmostv.by/" forHTTPHeaderField:@"Referer"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.account.username, @"login",
                            self.account.password, @"password",
                            @"1", @"doit!",
                            @"1", @"ajax",
                            nil];
    
    [self.httpClient POST:@"/subscribers/login/?process" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderCosmosTV.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSString * jsonString = [NSString stringWithFormat:@"%@", html];
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    
    if (![jsonObject isKindOfClass:[NSDictionary class]])
    {
        //это не json
        [self doFinish];
        return;
    }
        
    NSDictionary * jsonDictionary = (NSDictionary *)jsonObject;
    
    NSString * redirect = [jsonDictionary objectForKey:@"redirect"];
    if (!redirect)
    {
        //авторизация не прошла
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    NSString * path = [NSString stringWithFormat:@"http://cosmostv.by%@", redirect];
    [self.httpClient GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderCosmosTV.onStep2");
    //DDLogVerbose(@"%@", html);
    
    //showServices(this, "101932108", "41263"
    //http://cosmostv.by/json/subscribers/account/cabinet/?contract=101932108
    
    NSArray * arr = nil;
    NSString * buf = nil;
    NSDecimalNumber * num = nil;
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"showServices\\(this,\\s*\"([^\"]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        num = [self decimalNumberFromString:[arr objectAtIndex:0]];
    }
    
    if (!num)
    {
        [self doFinish];
        return;
    }
    

    NSString * path = [NSString stringWithFormat:@"http://cosmostv.by/json/subscribers/account/cabinet/?contract=%@", num];
    [self.httpClient GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep3:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step3 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];

}

- (void) onStep3:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderCosmosTV.onStep3");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    if (!html) return;
    
    NSString * jsonString = [NSString stringWithFormat:@"%@", html];
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    
    //это не json
    if (![jsonObject isKindOfClass:[NSDictionary class]]) return;

    
    NSDictionary * dict = (NSDictionary *) jsonObject;
    NSArray * services = [dict objectForKey:@"services"];
    if (!services || [services count] < 1) return;
    
    NSDictionary * service1 = [services objectAtIndex:0];
    if (![service1 isKindOfClass:[NSDictionary class]]) return;
    
    NSString * pbalance = [service1 objectForKey:@"pbalance"];
    if (!pbalance) return;
    
    self.loaderInfo.userBalance = [NSDecimalNumber decimalNumberWithString:pbalance];
    
    self.loaderInfo.extracted = YES;
}

@end
