//
//  BBLoaderAdslBy.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15/10/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//

#import "BBLoaderAdslBy.h"

@implementation BBLoaderAdslBy

- (void) startLoader
{
    [self prepareHttpClient:@"https://www.adsl.by/"];
    
    [self.httpClient.requestSerializer setAuthorizationHeaderFieldWithUsername:self.account.username password:self.account.password];
    
    [self.httpClient GET:@"/001.htm" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        [self extractInfoFromHtml:text];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        if ([error.localizedDescription rangeOfString:@"(401)"].location != NSNotFound) self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
    }];
}

@end
