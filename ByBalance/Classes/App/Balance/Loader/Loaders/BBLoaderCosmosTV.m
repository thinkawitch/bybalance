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
    [self prepareHttpClient:@"https://private.cosmostv.by:8443/"];
    
    // https://private.cosmostv.by:8443/group/cosmostv/balances
    
    [self.httpClient GET:@"/web/eshop/lk_auth" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}


- (void) onStep1:(NSString *)html
{
    DDLogVerbose(@"BBLoaderCosmosTV.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSArray * arr = nil;
    NSString * formUrl = nil;
    NSString * formDate = nil;
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<form.*action=\"([^\"]+)\".*id=\"_58_fm\"" caseInsensitive:YES treatAsOneLine:NO];
    //DDLogVerbose(@"arr: %@", arr);
    if (arr && [arr count] == 1)
    {
        formUrl = [arr objectAtIndex:0];
    }
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<input name=\"_58_formDate\" type=\"hidden\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        formDate = [arr objectAtIndex:0];
    }
    
    DDLogVerbose(@"formUrl: %@", formUrl);
    DDLogVerbose(@"formDate: %@", formDate);
    if (!formUrl || !formDate) [self doFinish];
    
    
    //decode %2F
    formUrl = [formUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DDLogVerbose(@"formUrl 2: %@", formUrl);
    
    //decode &amp;
    //formUrl = [formUrl stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    //DDLogVerbose(@"formUrl 3: %@", formUrl);
    
    //decode &amp;
    NSData * stringData = [formUrl dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * options = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSAttributedString * decodedString;
    decodedString = [[NSAttributedString alloc] initWithData:stringData
                                                     options:options
                                          documentAttributes:NULL
                                                       error:NULL];
    formUrl = decodedString.string;
    DDLogVerbose(@"formUrl 3: %@", formUrl);
    
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             formDate, @"_58_formDate",
                             @"", @"_58_redirect",
                             self.account.username, @"_58_login",
                             self.account.password, @"_58_password",
                             nil];
    DDLogVerbose(@"params: %@", params);
    
    [self.httpClient.requestSerializer setValue:@"https://private.cosmostv.by:8443/web/eshop/lk_auth" forHTTPHeaderField:@"Referer"];
    
    [self.httpClient POST:formUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep2:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ onStep1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    DDLogVerbose(@"BBLoaderCosmosTV.onStep2");
    DDLogVerbose(@"%@", html);
    
    //
    if ([html rangeOfString:@"portlet-msg-error"].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    [self doFinish];
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
    
    //TODO
    
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
