//
//  BBLoaderNiks.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderNiks.h"

@interface BBLoaderNiks ()

- (void) onStep1:(NSString *)html;

@end


@implementation BBLoaderNiks

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://user.niks.by/"];
    
    [self.httpClient GET:@"/Login.aspx" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderNiks.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSString * viewState = nil;
    NSArray * arr = [html stringsByExtractingGroupsUsingRegexPattern:@"name=\"__VIEWSTATE\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        viewState = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    DDLogVerbose(@"viewState %@", viewState);
    if ([viewState length] < 1)
    {
        [self doFinish];
        return;
    }
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             viewState, @"__VIEWSTATE",
                             self.account.username, @"LoginTxt",
                             self.account.password, @"PasswordTxt",
                             @"37", @"LoginImgBtn.x",
                             @"12", @"LoginImgBtn.y",
                             nil];
    
    [self.httpClient POST:@"/Login.aspx" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self extractInfoFromHtml:operation.responseString];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

@end
