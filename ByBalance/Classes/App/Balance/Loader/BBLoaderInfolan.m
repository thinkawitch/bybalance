//
//  BBLoaderInfolan.m
//  ByBalance
//
//  Created by Admin on 02.06.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderInfolan.h"
#import "XMLReader.h"

@implementation BBLoaderInfolan


#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"http://balance.infolan.by/balance_by.php";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setPostValue:account.username forKey:@"id"];
    [request setPostValue:account.password forKey:@"auth"];
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestFinished", [self class]);
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
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

#pragma mark - Logic

- (void) extractInfoFromHtml:(NSString *)html
{
    //NSLog(@"%@", html);
    
    if (!html)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSError * error = nil;
    NSDictionary * dict = [XMLReader dictionaryForXMLString:html
                                                    options:XMLReaderOptionsProcessNamespaces
                                                      error:&error];
    
    //NSLog(@"%@", dict);
    if (error || !dict)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    
    //correct response
    NSDictionary * nodeResp = [dict objectForKey:@"Response"];
    if (!nodeResp)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    //NSLog(@"%@", nodeResp);
    
    //has error
    if ([nodeResp objectForKey:@"Error"])
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary * nodeMain = [nodeResp objectForKey:@"Main"];
    if (!nodeMain)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary  * nodeBalance = [nodeMain objectForKey:@"Balance"];
    if (!nodeBalance)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    NSString  * textBalance = [nodeBalance objectForKey:@"text"];
    if (!textBalance)
    {
        loaderInfo.extracted = NO;
        return;
    }
    
    //NSLog(@"%@", textBalance);
    
    loaderInfo.userBalance = textBalance;
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    loaderInfo.extracted = YES;
}

@end
