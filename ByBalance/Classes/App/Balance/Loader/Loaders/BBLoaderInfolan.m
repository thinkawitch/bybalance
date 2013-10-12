//
//  BBLoaderInfolan.m
//  ByBalance
//
//  Created by Admin on 02.06.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderInfolan.h"

@implementation BBLoaderInfolan


#pragma mark - Logic

- (ASIFormDataRequest *) prepareRequest
{
    /*
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"http://balance.infolan.by/balance_by.php";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setPostValue:account.username forKey:@"id"];
    [request setPostValue:account.password forKey:@"auth"];
    
    return request;
     */
    return nil;
}

#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    /*
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
    */
}

#pragma mark - Logic

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
    
    
    //correct response
    NSDictionary * nodeResp = [dict objectForKey:@"Response"];
    if (!nodeResp)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    //NSLog(@"%@", nodeResp);
    
    //has error
    if ([nodeResp objectForKey:@"Error"])
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary * nodeMain = [nodeResp objectForKey:@"Main"];
    if (!nodeMain)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSDictionary  * nodeBalance = [nodeMain objectForKey:@"Balance"];
    if (!nodeBalance)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSString  * textBalance = [nodeBalance objectForKey:@"text"];
    if (!textBalance)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    //NSLog(@"%@", textBalance);
    
    self.loaderInfo.userBalance = textBalance;
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = YES;
}

@end
