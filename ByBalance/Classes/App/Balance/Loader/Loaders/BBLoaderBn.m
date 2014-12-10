//
//  BBLoaderBn.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderBn.h"

@interface BBLoaderBn ()
@end

@implementation BBLoaderBn

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://ui.bn.by/"];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.account.username, @"login",
                            self.account.password, @"passwd",
                            nil];
    
    [self.httpClient POST:@"/index.php?mode=login?locale=ru" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self extractInfoFromHtml:operation.responseString];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
    
}

@end
