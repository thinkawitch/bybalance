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
    BBBaseItem * baseItem = account.basicItem;

    NSURL * url = [NSURL URLWithString:baseItem.loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    //remember request data
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, baseItem, nil]
                                                   forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyBaseItem, nil]];
    
    [request addRequestHeader:@"Referer" value:baseItem.loginUrl];
    [request setPostValue:@"/wEPDwUKMTU5Mzk3MTA0NA9kFgJmD2QWAgICDxYCHgVjbGFzcwUFbG9naW4WAgICD2QWBgIBDw8WAh4JTWF4TGVuZ3RoAglkZAIDDw8WAh4DS0VZBSJjdGwwMF9NYWluQ29udGVudF9jYXB0Y2hhMzA2MjI5NzAwZGQCBQ8PFgYeBFRleHRlHghDc3NDbGFzcwUGc3VibWl0HgRfIVNCAgJkZGRq1lFdf8Isy5ch/s7SUIwpqQoOoA==" forKey:@"__VIEWSTATE"];
    [request setPostValue:account.username forKey:@"ctl00$MainContent$tbPhoneNumber"];
    [request setPostValue:account.password forKey:@"ctl00$MainContent$tbPassword"];
    [request setPostValue:@"Войти" forKey:@"ctl00$MainContent$btnEnter"];
    
    request.delegate = self;
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestStarted", [self class]);
    NSLog(@"url: %@", request.url);
    
    
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFinished", [self class]);
    
    
    
    [self markDone];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFailed" , [self class]);
    NSLog(@"%@", [request error]);
    
    loaderFinished = YES;
    loaderExecuting = NO;
}


@end
