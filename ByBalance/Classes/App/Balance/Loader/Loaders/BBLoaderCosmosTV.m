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
- (void) processAllContracts;
- (void) doOneContract:(NSString *)cid;
- (void) onOneContract:(NSString *)cid withHtml:(NSString *)html;
- (BBLoaderInfo *) extractCosmosTvFromHtml:(NSString *)html;

@property NSString * contractFormUrl;
@property NSMutableDictionary * contracts;

@end


@implementation BBLoaderCosmosTV

@synthesize contracts;
@synthesize contractFormUrl;

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://private.cosmostv.by:8443/"];
    
    self.contracts = [NSMutableDictionary dictionary];
    
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
    formUrl = [self fixUrlEncoding:formUrl];
    DDLogVerbose(@"formUrl fixed: %@", formUrl);
    if (!formUrl) [self doFinish];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             formDate, @"_58_formDate",
                             @"", @"_58_redirect",
                             self.account.username, @"_58_login",
                             self.account.password, @"_58_password",
                             nil];
    DDLogVerbose(@"params: %@", params);
    
    //[self.httpClient.requestSerializer setValue:@"https://private.cosmostv.by:8443/web/eshop/lk_auth" forHTTPHeaderField:@"Referer"];
    
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
    //DDLogVerbose(@"%@", html);
    
    //
    if ([html rangeOfString:@"portlet-msg-error"].location != NSNotFound)
    {
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    NSArray * arr = nil;
    
    //check contracts form
    NSString * formUrl = nil;
    NSString * contractsHtml = nil;
    
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<form id=\"frm_contracts\" action=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        formUrl = [arr objectAtIndex:0];
        formUrl = [self fixUrlEncoding:formUrl];
    }
    
    if (formUrl)
    {
        self.contractFormUrl = formUrl;
        
        //form exists, might be multiple contracts
        DDLogVerbose(@"contractFormUrl: %@", contractFormUrl);
        
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"<select\\s*id\\s*=\\s*\"contracts\"[^>]+>(.*)</select>" caseInsensitive:YES treatAsOneLine:NO];
        //DDLogVerbose(@"arr: %@", arr);
        // <option value="101909390" selected class = "" > TO_7518 </option> <option value="101910260" class = "" > 40399 </option>
        if (arr && [arr count] == 1)
        {
            contractsHtml = [arr objectAtIndex:0];
        }
        DDLogVerbose(@"contractsHtml %@", contractsHtml);
        
        if (contractsHtml)
        {
            arr = [contractsHtml stringsByExtractingGroupsUsingRegexPattern:@"<option\\s*value=\"([^\"]+)\"[^>]*>([^<]+)</option>" caseInsensitive:YES treatAsOneLine:NO];
            DDLogVerbose(@"arr: %@", arr);
            if (arr && [arr count] > 0)
            {
                NSString * cid = @"";
                NSString * cname = @"";
                for (uint i=0; i<arr.count; i++)
                {
                    BOOL isKey = (i + 1) % 2 ? YES : NO;
                    
                    NSString * val = [PRIMITIVE_HELPER trimmedString:[arr objectAtIndex:i]];
                    DDLogVerbose(@"isKey: %@ %d", val, isKey);
                    if (isKey) cid = val;
                    else cname = val;
                    
                    [self.contracts setValue:cname forKey:cid];
                }
            }
            
            //exclude tech contracts
            for (NSString * cid in [contracts allKeys])
            {
                NSString * cname = [contracts objectForKey:cid];
                if ([cname hasPrefix:@"TO_"]) [contracts removeObjectForKey:cid];
            }
            
            DDLogVerbose(@"contracts: %@", contracts);
        }
    }
    
    
    if (contracts.count > 0)
    {
        [self processAllContracts];
    }
    else
    {
        self.loaderInfo = [self extractCosmosTvFromHtml:html];
        [self doFinish];
    }
}

- (void) processAllContracts
{
    //search next
    for (NSString * cid in contracts)
    {
        NSObject * obj = [contracts objectForKey:cid];
        if (![obj isKindOfClass:[BBLoaderInfo class]])
        {
            [self doOneContract:cid];
            return;
        }
    }
    
    //all loaded, combine results
    NSMutableArray * lines = [NSMutableArray array];
    NSDecimalNumber * maxBalance = [[NSDecimalNumber alloc] initWithInt:0];
    BOOL atLeastOne = NO;
    
    for (NSString * cid2 in contracts)
    {
        BBLoaderInfo * info = [contracts objectForKey:cid2];
        if (info.extracted) atLeastOne = YES;
        if (info.extracted && [maxBalance compare:info.userBalance] == NSOrderedAscending) maxBalance = info.userBalance;
        if (info.bonuses) [lines addObject:info.bonuses];
    }
    
    if (atLeastOne)
    {
        self.loaderInfo.extracted = YES;
        self.loaderInfo.userBalance = maxBalance;
        self.loaderInfo.bonuses = [lines componentsJoinedByString:@"\n"];
    }
    
    [self doFinish];
}

- (void) doOneContract:(NSString *)cid
{
    DDLogVerbose(@"BBLoaderCosmosTV.doOneContract %@", cid);
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             cid, @"id_contract",
                             nil];
    
    [self.httpClient POST:self.contractFormUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onOneContract:cid withHtml:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ doOneContract httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onOneContract:(NSString *)cid withHtml:(NSString *)html
{
    BBLoaderInfo * info = [self extractCosmosTvFromHtml:html];
    [self.contracts setValue:info forKey:cid];
    
    [self processAllContracts];
}

- (BBLoaderInfo *) extractCosmosTvFromHtml:(NSString *)html;
{
    NSInteger type = [self.account.type.id integerValue];
    return [BASES_MANAGER extractInfoForType:type fromHtml:html];
}

@end
