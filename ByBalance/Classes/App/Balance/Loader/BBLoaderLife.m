//
//  BBLoaderLife.m
//  ByBalance
//
//  Created by Admin on 17.11.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderLife.h"

@implementation BBLoaderLife

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"https://issa.life.com.by/";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    NSString * s1 = [account.username substringToIndex:2];
    NSString * s2 = [account.username substringFromIndex:2];
    
    [request addRequestHeader:@"Referer" value:loginUrl];
    [request setPostValue:s1 forKey:@"Code"];
    [request setPostValue:account.password forKey:@"Password"];
    [request setPostValue:s2 forKey:@"Phone"];
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFinished", [self class]);
    
    if ([self.delegate respondsToSelector:@selector(balanceLoaderSuccess:)] )
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, request.responseString, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyHtml, nil]];
        
        [self.delegate balanceLoaderSuccess:info];
    }
    
    [self markDone];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFailed" , [self class]);
    NSLog(@"%@", [request error]);
    
    if ([self.delegate respondsToSelector:@selector(balanceLoaderFail:)] )
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, nil]];
        
        [self.delegate balanceLoaderFail:info];
    }
    
    [self markDone];
}

@end
