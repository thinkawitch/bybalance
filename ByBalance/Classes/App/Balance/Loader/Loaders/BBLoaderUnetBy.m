//
//  BBLoaderUnetBy.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 14.07.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderUnetBy.h"

NSString * const kUnetKey = @"dce5ff68a9094f749cd73cfc794cdd45";

@interface BBLoaderUnetBy()

@property (nonatomic,strong) NSString * sessionId;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end


@implementation BBLoaderUnetBy

@synthesize sessionId;

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://my.unet.by/"];
    
    NSString * loginUrl = [NSString stringWithFormat:@"https://my.unet.by/api/login?api_key=%@&login=%@&pass=%@",
                           kUnetKey, self.account.username, self.account.password];
    
    [self.httpClient GET:loginUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step1 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderUnetBy.onStep1");
    //DDLogVerbose(@"%@", html);
    
    NSError * error = nil;
    NSDictionary * dict = [XMLReader dictionaryForXMLString:html
                                                    options:XMLReaderOptionsProcessNamespaces
                                                      error:&error];
    
    if (error || !dict)
    {
        [self doFinish];
        return;
    }
    
    NSDictionary * nodeRes = [dict objectForKey:@"res"];
    if (!nodeRes)
    {
        [self doFinish];
        return;
    }
    
    NSDictionary * nodeTag = [nodeRes objectForKey:@"tag"];
    if (!nodeTag)
    {
        [self doFinish];
        return;
    }
    
    NSDictionary * nodeSession = [nodeTag objectForKey:@"session"];
    if (!nodeSession)
    {
        [self doFinish];
        return;
    }
    
    
    NSString  * session = nil;
    
    if ([nodeSession isKindOfClass:[NSString class]])
    {
        session = (NSString*)nodeSession;
    }
    else if ([nodeSession isKindOfClass:[NSDictionary class]])
    {
        session = [nodeSession objectForKey:@"text"];
    }
    
    if (!session || ![session isKindOfClass:[NSString class]] || [session length] < 1)
    {
        [self doFinish];
        return;
    }
    
    self.sessionId = session;
    //DDLogVerbose(@"session: %@", self.sessionId);
    
    NSString * infoUrl = [NSString stringWithFormat:@"https://my.unet.by/api/info?api_key=%@&sid=%@", kUnetKey, self.sessionId];
    
    [self.httpClient GET:infoUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self onStep2:text];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ step2 httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //DDLogVerbose(@"BBLoaderUnetBy.onStep2");
    //DDLogVerbose(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    //DDLogVerbose(@"%@", html);
    if (!html) return;
    
    NSError * error = nil;
    NSDictionary * dict = [XMLReader dictionaryForXMLString:html
                                                    options:XMLReaderOptionsProcessNamespaces
                                                      error:&error];
    
    //DDLogVerbose(@"%@", dict);
    if (error || !dict) return;
    
    NSDictionary * nodeResp = [dict objectForKey:@"res"];
    if (!nodeResp) return;
    
    NSDictionary * nodeTag = [nodeResp objectForKey:@"tag"];
    if (!nodeTag) return;
    
    NSDictionary * nodeDeposit = [nodeTag objectForKey:@"deposit"];
    if (!nodeDeposit) return;
    
    NSString * textBalance = nil;
    
    if ([nodeDeposit isKindOfClass:[NSString class]])
    {
        textBalance = (NSString*)nodeDeposit;
    }
    else if ([nodeDeposit isKindOfClass:[NSDictionary class]])
    {
        textBalance = [nodeDeposit objectForKey:@"text"];
    }
    
    if (!textBalance || ![textBalance isKindOfClass:[NSString class]] || [textBalance length] < 1)
    {
        [self doFinish];
        return;
    }
    
    self.loaderInfo.userBalance = [NSDecimalNumber decimalNumberWithString:textBalance];
    //self.loaderInfo.userBalance = textBalance;
    //DDLogVerbose(@"balance: %@", self.loaderInfo.userBalance);
    
    self.loaderInfo.extracted = YES;
}


@end
