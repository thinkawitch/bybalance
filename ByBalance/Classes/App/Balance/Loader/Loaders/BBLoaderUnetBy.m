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
    [self clearCookies:@"https://my.unet.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://my.unet.by/"]];
    [self setDefaultsForHttpClient];
    
    NSString * loginUrl = [NSString stringWithFormat:@"https://my.unet.by/api/login?api_key=%@&login=%@&pass=%@",
                           kUnetKey, self.account.username, self.account.password];
    
    [self.httpClient getPath:loginUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderUnetBy.onStep1");
    //NSLog(@"%@", html);
    
    NSError * error = nil;
    NSDictionary * dict = [XMLReader dictionaryForXMLString:html
                                                    options:XMLReaderOptionsProcessNamespaces
                                                      error:&error];
    
    //NSLog(@"%@", dict);
    if (error || !dict)
    {
        [self doFinish];
        return;
    }
    
    NSDictionary * nodeResp = [dict objectForKey:@"res"];
    if (!nodeResp)
    {
        [self doFinish];
        return;
    }
    
    nodeResp = [nodeResp objectForKey:@"tag"];
    if (!nodeResp)
    {
        [self doFinish];
        return;
    }
    
    NSString  * session = [nodeResp objectForKey:@"session"];
    if (!session || [session length] < 1)
    {
        [self doFinish];
        return;
    }
    
    self.sessionId = session;
    //NSLog(@"session: %@", self.sessionId);
    
    NSString * infoUrl = [NSString stringWithFormat:@"https://my.unet.by/api/info?api_key=%@&sid=%@", kUnetKey, self.sessionId];
    
    [self.httpClient getPath:infoUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self onStep2:text];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderUnetBy.onStep2");
    //NSLog(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    //NSLog(@"%@", html);
    if (!html)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSError * error = nil;
    NSDictionary * dict = [XMLReader dictionaryForXMLString:html
                                                    options:XMLReaderOptionsProcessNamespaces
                                                      error:&error];
    
    //NSLog(@"%@", dict);
    if (error || !dict)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary * nodeResp = [dict objectForKey:@"res"];
    if (!nodeResp)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary * nodeTag = [nodeResp objectForKey:@"tag"];
    if (!nodeTag)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary * nodeDeposit = [nodeTag objectForKey:@"deposit"];
    if (!nodeDeposit)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSString * textBalance = [nodeDeposit objectForKey:@"text"];
    if (!textBalance)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    self.loaderInfo.userBalance = textBalance;
    //NSLog(@"balance: %@", self.loaderInfo.userBalance);
    
    self.loaderInfo.extracted = YES;
}


@end
