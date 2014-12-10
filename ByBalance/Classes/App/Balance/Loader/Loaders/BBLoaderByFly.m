//
//  BBLoaderByFly.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderByFly.h"

@interface BBLoaderByFly ()
@end


@implementation BBLoaderByFly

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://issa.beltelecom.by/"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.account.username, @"oper_user",
                            self.account.password, @"passwd",
                            @"/main.html", @"redirect",
                            nil];
    //DDLogVerbose(@"%@", params);
  
    [self.httpClient POST:@"main.html" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSString *response1 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        NSString * response = operation.responseString;
        //DDLogVerbose(@"Response:\n%@", response);
        
        [self extractInfoFromHtml:response];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

@end
