//
//  BBLoaderVelcom.m
//  ByBalance
//
//  Created by Admin on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderVelcom.h"

@implementation BBLoaderVelcom

- (ASIFormDataRequest *) prepareRequest
{
    NSString * loginUrl = @"httpsd://internet.velcom.by/work.html";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request addRequestHeader:@"Referer" value:loginUrl];
    //[request setPostValue:account.username forKey:@"login"];
    //[request setPostValue:account.password forKey:@"passwd"];
    
    request.delegate = self;
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    //NSLog(@"%@.requestStarted", [self class]);
    NSLog(@"url: %@", request.url);
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFinished", [self class]);
    
    [self markDone];
    
    if ([self.delegate respondsToSelector:@selector(balanceLoaderSuccess:)] )
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, request.responseString, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyHtml, nil]];
        
        [self.delegate balanceLoaderSuccess:info];
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFailed" , [self class]);
    NSLog(@"%@", [request error]);
    
    [self markDone];
    
    if ([self.delegate respondsToSelector:@selector(balanceLoaderFail:)] )
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, nil]];
        
        [self.delegate balanceLoaderFail:info];
    }
}

@end
