//
//  BBLoaderAnitex.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/5/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderAnitex.h"

@implementation BBLoaderAnitex

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://stat.anitex.by/"];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.account.username, @"username",
                             self.account.password, @"password",
                             @"dialup", @"type",
                             nil];
    
    [self.httpClient POST:@"/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response2 = [[NSString alloc] initWithData:responseObject encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingKOI8_R)];
        
        [self extractInfoFromHtml:response2];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
    
}

@end
