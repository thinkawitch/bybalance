//
//  BBLoaderLife.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17.11.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderLife.h"

@interface BBLoaderLife ()

@property (nonatomic,strong) NSString * middlewareToken;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end

@implementation BBLoaderLife

@synthesize middlewareToken;

#pragma mark - Logic



- (void) OLD_startLoader
{
    [self prepareHttpClient:@"https://issa.life.com.by/"];
    
    NSString * s1 = [self.account.username substringToIndex:2];
    NSString * s2 = [self.account.username substringFromIndex:2];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             s1, @"Code",
                             self.account.password, @"Password",
                             s2, @"Phone",
                             nil];
    
    [self.httpClient POST:@"/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self extractInfoFromHtml:operation.responseString];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        //[self doFinish];
        
        [self prepareHttpClient:@"https://issa2.life.com.by/"];
        
        [self.httpClient POST:@"/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self extractInfoFromHtml:operation.responseString];
            [self doFinish];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
            [self doFinish];
        }];
    }];
}


- (void) startLoader
{
    [self prepareHttpClient:@"https://issa.life.com.by/"];
    
    [self.httpClient GET:@"/ru/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderLife.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSArray * arr = nil;
    
    //try to detect session
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"name=\"csrfmiddlewaretoken\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.middlewareToken = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    else
    {
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"name='csrfmiddlewaretoken' value='([^']+)'" caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            self.middlewareToken = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
        }
    }
    
    //DDLogVerbose(@"middlewareToken: %@", self.middlewareToken);
    
    if (!self.middlewareToken)
    {
        [self doFinish];
        return;
    }
    
    NSString * s1 = [self.account.username substringToIndex:2];
    NSString * s2 = [self.account.username substringFromIndex:2];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.middlewareToken, @"csrfmiddlewaretoken",
                             s1, @"msisdn_code",
                             s2, @"msisdn",
                             self.account.password, @"super_password",
                             @"true", @"form",
                             @"/", @"next",
                             nil];
    

    //[self.httpClient setDefaultHeader:@"Referer" value:@"https://issa.life.com.by/ru/"];
    [self.httpClient.requestSerializer setValue:@"https://issa.life.com.by/ru/" forHTTPHeaderField:@"Referer"];
    
    [self.httpClient POST:@"/ru/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        DDLogInfo(@"%@", operation.responseString);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderLife.onStep2");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}


- (void) extractInfoFromHtml:(NSString *)html
{
    NSArray * arr = nil;
    BOOL extracted = NO;
    
    //DDLogVerbose(@"%@", html);
    //DDLogVerbose(@"------------");
    //DDLogVerbose(@"------------");
    
    BOOL loggedIn = ([html rangeOfString:@"class=\"log-out\""].location != NSNotFound);
    if (!loggedIn)
    {
        //incorrect login/pass
        self.loaderInfo.incorrectLogin = true;
        return;
    }
    
    
    //userTitle
    /*
     <div class="divBold">Фамилия:</div>
     <div>
     */
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"ФИО\\s*</td>\\s*<td[^>]*>([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userTitle = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userTitle: %@", self.loaderInfo.userTitle);
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Наименование тарифного плана\\s*</td>\\s*<td[^>]*>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        self.loaderInfo.userPlan = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:0]];
    }
    //DDLogVerbose(@"userPlan: %@", self.loaderInfo.userPlan);
    
    //balance
    //arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Основной баланс\\s*</td>\\s*<td>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Основной баланс\\s*</td>\\s*<td[^>]*>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        NSString * str = [arr objectAtIndex:0];
        NSRange range = [str rangeOfString:@"руб"];
        if (range.location != NSNotFound)
        {
            NSString * newStr = [str substringToIndex:range.location];
            self.loaderInfo.userBalance = [self decimalNumberFromString:newStr];
        }
        else
        {
            self.loaderInfo.userBalance = [self decimalNumberFromString:str];
        }
        extracted = YES;
        
    }
    //DDLogVerbose(@"balance: %@", self.loaderInfo.userBalance);
    
    
    self.loaderInfo.extracted = extracted;
}

@end
