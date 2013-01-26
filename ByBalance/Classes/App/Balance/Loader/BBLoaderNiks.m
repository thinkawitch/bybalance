//
//  BBLoaderNiks.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderNiks.h"

@implementation BBLoaderNiks

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"https://user.niks.by/Login.aspx";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setPostValue:@"dDwtOTM5ODc5MjcyOztsPExvZ2luSW1nQnRuOz4+LWAmSvmShzbE7AkSAWCVT7wVAJo=" forKey:@"__VIEWSTATE"];
    [request setPostValue:account.username forKey:@"LoginTxt"];
    [request setPostValue:account.password forKey:@"PasswordTxt"];
    [request setPostValue:@"37" forKey:@"LoginImgBtn.x"];
    [request setPostValue:@"12" forKey:@"LoginImgBtn.y"];

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
