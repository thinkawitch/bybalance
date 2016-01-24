//
//  BBLoaderDamavik.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderDamavik.h"

@interface BBLoaderDamavik ()
{
    BOOL isDamavik;
    BOOL isAtlant;
}

@property (nonatomic,strong) NSString * baseUrl;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

@end


@implementation BBLoaderDamavik

#pragma mark - Logic

- (void) actAsDamavik
{
    self.baseUrl = @"https://issa.telecom.by/";
    isDamavik = YES;
}

- (void) actAsAtlantTelecom
{
    self.baseUrl = @"https://issa2b.telecom.by/";
    isAtlant = YES;
}

- (void) startLoader
{
    [self prepareHttpClient:self.baseUrl];

    [self.httpClient GET:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderDamavik.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSArray * arr = nil;
    
    //search for captcha image
    
    NSString * imgName = nil;
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<img src=\"/img/_cap/items/([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        imgName = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    
    //DDLogVerbose(@"imgName: %@", imgName);
    
    if (!imgName)
    {
        [self doFinish];
        return;
    }
    
    //load captcha image to get cookies
    NSString * captchaUrl = [NSString stringWithFormat:@"/img/_cap/items/%@", imgName];
    
    [self.httpClient GET:captchaUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self onStep2:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderDamavik.onStep2");
    
    if (!isAtlant && !isDamavik)
    {
        [self doFinish];
        return;
    }

    NSString *formAction = [NSString stringWithFormat:@"%@about", self.baseUrl];
    NSDictionary *params = nil;

    if (isDamavik)
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  @"login", @"action__n18",
                  formAction, @"form_action_true",
                  self.account.username, @"login__n18",
                  self.account.password, @"password__n18",
                  nil];
    }
    else if (isAtlant)
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  @"login", @"action__n28",
                  formAction, @"form_action_true",
                  self.account.username, @"login__n28",
                  self.account.password, @"password__n28",
                  nil];
    }
    
    //DDLogVerbose(@"BBLoaderDamavik.step2 params %@", params);

    [self.httpClient POST:self.baseUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep3:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step3 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep3:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderDamavik.onStep3");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

@end
