//
//  BBLoaderMts.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderMts.h"

@interface BBLoaderMts ()

@property (nonatomic,strong) NSString * paramViewState;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end


@implementation BBLoaderMts

@synthesize paramViewState;

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://ihelper.mts.by/"];
    
    [self.httpClient GET:@"/SelfCare/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderMts.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSArray * arr = nil;
    
    //try to detect session
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"id=\"__VIEWSTATE\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.paramViewState = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    
    //DDLogVerbose(@"paramViewState: %@", self.paramViewState);
    
    if (!self.paramViewState)
    {
        [self doFinish];
        return;
    }

    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.paramViewState, @"__VIEWSTATE",
                             self.account.username, @"ctl00$MainContent$tbPhoneNumber",
                             self.account.password, @"ctl00$MainContent$tbPassword",
                             @"Войти", @"ctl00$MainContent$btnEnter",
                             nil];
    
    [self.httpClient POST:@"/SelfCare/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderMts.onStep2");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

@end
