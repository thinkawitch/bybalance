//
//  BBLoaderUnetBy.m
//  ByBalance
//
//  Created by Admin on 14.07.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderUnetBy.h"

#define UNET_KEY @"dce5ff68a9094f749cd73cfc794cdd45"

@interface BBLoaderUnetBy()

@property (nonatomic,strong) NSString * sessionId;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

@end


@implementation BBLoaderUnetBy

@synthesize  sessionId;

#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    /*
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = [NSString stringWithFormat:@"https://my.unet.by/api/login?api_key=%@&login=%@&pass=%@",
                                                    UNET_KEY, account.username, account.password];
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    return request;
     */
    
    return nil;
}

#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    /*
    //NSLog(@"%@.requestFinished", [self class]);
    
    NSString * step = [request.userInfo objectForKey:@"step"];
    
    //NSLog(@"responseEncoding %d", request.responseEncoding);
    
    NSString * html = nil;
    if (request.responseEncoding == NSISOLatin1StringEncoding)
    {
        html = [[[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding] autorelease];
    }
    else
    {
        html = request.responseString;
    }
    
    if ([step isEqualToString:@"1"])
    {
        [self onStep1:html];
    }
    else if ([step isEqualToString:@"2"])
    {
        [self onStep2:html];
    }
    else
    {
        [self doFinish];
    }
     */
}


#pragma mark - Logic

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
    /*
    NSString * infoUrl = [NSString stringWithFormat:@"https://my.unet.by/api/info?api_key=%@&sid=%@", UNET_KEY, self.sessionId];
    
    
    NSURL * url = [NSURL URLWithString:infoUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    //start request
    [request startAsynchronous];
     */
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
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = YES;
}


@end
