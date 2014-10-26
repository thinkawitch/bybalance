//
//  BBLoaderVelcom.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderVelcom.h"

NSString * const kUrlVelcom = @"https://internet.velcom.by/";

@interface BBLoaderVelcom ()
{
    NSInteger webViewLoads;
    BOOL x3Started;
    BOOL webViewFinished;
    
}
@property (nonatomic,strong) UIWebView * webView;
@property (nonatomic,strong) NSString * sessionId;
@property (nonatomic,assign) BOOL loggedIn;
@property (nonatomic,strong) NSString * menuMarker;

- (void) onStep0;
- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;
- (void) checkIfLoggedInHtml:(NSString *) html;

@end


@implementation BBLoaderVelcom

@synthesize webView;
@synthesize sessionId;

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DDLogVerbose(@"webView shouldStartLoadWithRequest: %@", request.URL);
    //DDLogVerbose(@"%@", request.allHTTPHeaderFields);
    DDLogVerbose(@"webView shouldStartLoadWithRequest willLoad: %d", !webViewFinished);
    
    if ([request.URL.relativeString rangeOfString:@"X3_"].location != NSNotFound) {
        DDLogVerbose(@"X3 started: %@", request.URL.relativeString);
        x3Started = YES;
    }
    
    return !webViewFinished;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    webViewLoads++;
    DDLogVerbose(@"webViewDidStartLoad %ld", webViewLoads);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webViewLoads--;
    DDLogVerbose(@"webViewDidFinishLoad %ld", webViewLoads);
    if (webViewLoads <= 0 && x3Started)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        webViewFinished = YES;
        [self onStep0];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogVerbose(@"webView didFailLoadWithError: %@", error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    webViewLoads--;
    webViewFinished = YES;
    [self doFinish];
}

#pragma mark - Logic

- (void) startLoader
{
    [self showCookies:kUrlVelcom];
    [self prepareHttpClient:kUrlVelcom];
    
    self.loggedIn = NO;
    self.menuMarker = @"";
    
    webViewLoads = 0;
    webViewFinished = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.webView.delegate = self;
        NSURL *url = [NSURL URLWithString:kUrlVelcom];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:urlRequest];
    });
    
    /*
     dispatch_async(dispatch_get_main_queue(), ^(void){
     self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 168, 320, 400)];
     self.webView.delegate = self;
     [[[[UIApplication sharedApplication] delegate] window] addSubview:self.webView];
     NSURL *url = [NSURL URLWithString:kUrlVelcom];
     NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
     [self.webView loadRequest:urlRequest];
     });
     */

}

- (void) onStep0
{
    DDLogVerbose(@"BBLoaderVelcom.onStep0");
    [self showCookies:kUrlVelcom];
    
    //NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    //[self onStep1:html];
    
    [self.httpClient GET:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
    
}

- (void) onStep1:(NSString *)html
{
    DDLogVerbose(@"BBLoaderVelcom.onStep1");
    [self showCookies:kUrlVelcom];
    //DDLogVerbose(@"%@", html);
    
    NSArray * arr = nil;
    
    //try to detect session
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"name=\"sid3\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.sessionId = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    
    DDLogVerbose(@"sessionId: %@", self.sessionId);
    
    if (!self.sessionId)
    {
        [self doFinish];
        return;
    }
    
    NSNumber * ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    NSString * s1 = [self.account.username substringToIndex:2];
    s1 = [NSString stringWithFormat:@"375%@", s1];
    NSString * s2 = [self.account.username substringFromIndex:2];
    
    [self.httpClient POST:@"/work.html" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFormData:[self.sessionId dataUsingEncoding:NSUTF8StringEncoding] name:@"sid3"];
        [formData appendPartWithFormData:[[ts stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_timestamp"];
        [formData appendPartWithFormData:[@"_next" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_0"];
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"last_id"];
        //[formData appendPartWithFormData:[@"5" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_8"];
        [formData appendPartWithFormData:[s1 dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_1"];
        [formData appendPartWithFormData:[s2 dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_2"];
        [formData appendPartWithFormData:[self.account.password dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_3"];
        //[formData appendPartWithFormData:[@"2" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_9"];
        //[formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_10"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    DDLogVerbose(@"BBLoaderVelcom.onStep2");
    [self showCookies:kUrlVelcom];
    //DDLogVerbose(@"%@", html);
    
    [self checkIfLoggedInHtml:html];

    if (!self.loggedIn)
    {
        //maybe login problem
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    NSNumber * ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    [self.httpClient POST:@"/work.html" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFormData:[self.sessionId dataUsingEncoding:NSUTF8StringEncoding] name:@"sid3"];
        [formData appendPartWithFormData:[[ts stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_timestamp"];
        [formData appendPartWithFormData:[self.menuMarker dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_0"];
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"last_id"];
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_1"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep3:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step3 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}


- (void) onStep3:(NSString *)html
{
    DDLogVerbose(@"BBLoaderVelcom.onStep3");
    [self showCookies:kUrlVelcom];
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    NSArray * arr = nil;
    
    [self checkIfLoggedInHtml:html];
    
    if (!self.loggedIn)
    {
        //incorrect login/pass
        self.loaderInfo.incorrectLogin = ([html rangeOfString:@"INFO_Error_caption"].location != NSNotFound);
        //DDLogVerbose(@"incorrectLogin: %d", incorrectLogin);
        
        if (self.loaderInfo.incorrectLogin) return;
    }
    
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td[^>]*id=\"NAME\"[^>]*><span>\\s*([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userTitle = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userTitle: %@", self.loaderInfo.userTitle);
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td[^>]*id=\"TPLAN\"[^>]*><span>\\s*([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userPlan = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userPlan: %@", self.loaderInfo.userPlan);
    
    //bonuses
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<td[^>]*id=\"DISCOUNT\"[^>]*><span>\\s*([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.bonuses = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
        self.loaderInfo.bonuses = [NSString stringWithFormat:@"%@ а также еще 150 смс сообщений и очень очень много траффика. Акции и бонусы уже в пути! Да и счастье не за горами, подождите всего 100 лет и 3 года.", self.loaderInfo.bonuses];
    }
    //DDLogVerbose(@"bonuses: %@", self.loaderInfo.bonuses);
    
    NSDecimalNumber * balance = nil;
    NSArray * balanceMarkers = [NSArray arrayWithObjects:
                                @"Текущий баланс:</td><td class=\"INFO\">([^<]+)",
                                @"Баланс:</td><td class=\"INFO\">([^<]+)",
                                @"Начисления\\s*абонента\\*:</td><td class=\"INFO\">([^<]+)",
                                @"<td[^>]*id=\"BALANCE\"[^>]*><span>\\s*([^<]+)",
                                nil];
    
    for (NSString * bm in balanceMarkers)
    {
        arr = [html stringsByExtractingGroupsUsingRegexPattern:bm caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            balance = [self decimalNumberFromString:[arr objectAtIndex:0]];
            if (nil != balance)
            {
                self.loaderInfo.userBalance = balance;
                self.loaderInfo.extracted = YES;
            }
        }
    }
}

- (void) checkIfLoggedInHtml:(NSString *) html;
{
    self.loggedIn = NO;
    self.menuMarker = @"";
    NSArray * menuMarkers = [NSArray arrayWithObjects:@"_root/USER_INFO", @"_root/MENU0", @"_root/PERSONAL_INFO", nil];
    
    for (NSString * marker in menuMarkers)
    {
        if ([html rangeOfString:marker].location != NSNotFound)
        {
            self.menuMarker = marker;
            self.loggedIn = YES;
            break;
        }
    }
}

@end
