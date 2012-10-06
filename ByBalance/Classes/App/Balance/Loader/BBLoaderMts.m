//
//  BBLoaderMts.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderMts.h"

@implementation BBLoaderMts

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString * loginUrl = @"https://ihelper.mts.by/SelfCare/logon.aspx";

    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    //remember request data
    //request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, baseItem, nil]
    //                                               forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyBaseItem, nil]];
    
    [request addRequestHeader:@"Referer" value:loginUrl];
    [request setPostValue:@"/wEPDwUKMTU5Mzk3MTA0NA9kFgJmD2QWAgICDxYCHgVjbGFzcwUFbG9naW4WAgICD2QWBgIBDw8WAh4JTWF4TGVuZ3RoAglkZAIDDw8WAh4DS0VZBSJjdGwwMF9NYWluQ29udGVudF9jYXB0Y2hhMzA2MjI5NzAwZGQCBQ8PFgYeBFRleHRlHghDc3NDbGFzcwUGc3VibWl0HgRfIVNCAgJkZGRq1lFdf8Isy5ch/s7SUIwpqQoOoA==" forKey:@"__VIEWSTATE"];
    [request setPostValue:account.username forKey:@"ctl00$MainContent$tbPhoneNumber"];
    [request setPostValue:account.password forKey:@"ctl00$MainContent$tbPassword"];
    [request setPostValue:@"Войти" forKey:@"ctl00$MainContent$btnEnter"];
    
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
