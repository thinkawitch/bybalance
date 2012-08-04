//
//  BBLoaderBase.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderBase.h"
#import "ASIFormDataRequest.h"

@interface BBLoaderBase()
- (void) handleIncorrectResponse;
- (ASIFormDataRequest *) requestWithURL:(NSURL *)anUrl;
@end;


@implementation BBLoaderBase

@synthesize item;
@synthesize delegate;

#pragma mark - ObjectLife

- (void) dealloc
{
    self.item = nil;
    
    [super dealloc];
}

#pragma mark - Logic

- (void) start
{
    item.isBanned = NO;
    item.isExtracted = NO;
    
    [self login];
}

- (void) login
{
    NSURL * url = [NSURL URLWithString:item.loginUrl];
    
	NSLog(@"url: %@", url);
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    request.delegate = self;
    //request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:kServerCommandGetAllVideos], nil] 
    //                                               forKeys:[NSArray arrayWithObjects:kDictKeyApiServerCommandType, nil]];

    [request addRequestHeader:@"Referer" value:item.loginUrl];
    [request setPostValue:@"/wEPDwUKMTU5Mzk3MTA0NA9kFgJmD2QWAgICDxYCHgVjbGFzcwUFbG9naW4WAgICD2QWBgIBDw8WAh4JTWF4TGVuZ3RoAglkZAIDDw8WAh4DS0VZBSJjdGwwMF9NYWluQ29udGVudF9jYXB0Y2hhMzA2MjI5NzAwZGQCBQ8PFgYeBFRleHRlHghDc3NDbGFzcwUGc3VibWl0HgRfIVNCAgJkZGRq1lFdf8Isy5ch/s7SUIwpqQoOoA==" forKey:@"__VIEWSTATE"];
    [request setPostValue:item.username forKey:@"ctl00$MainContent$tbPhoneNumber"];
    [request setPostValue:item.password forKey:@"ctl00$MainContent$tbPassword"];
    [request setPostValue:@"Войти" forKey:@"ctl00$MainContent$btnEnter"];
    
    
    [request startAsynchronous];
}

- (void) getDetails
{
    
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"BBLoaderBase.requestStarted");
    NSLog(@"url: %@", request.url);
    NSLog(@"userAgent: %@", request.userAgentString);
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"BBLoaderBase.requestFinished");
    NSLog(@"%@", request.responseString);
    
    //find data
    [item extractFromHtml:request.responseString];
    
    if (nil == delegate) return;
    
    if (item.isExtracted)
    {
        [delegate performSelector:@selector(dataLoaderSuccess:) withObject:self];
    }
    else
    {
        [delegate performSelector:@selector(dataLoaderFail:) withObject:self];
    }
    
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"BBLoaderBase.requestFailed");
    NSLog(@"%@", request.responseString);
    
    if (nil == delegate) return;
    
    [delegate performSelector:@selector(dataLoaderFail:) withObject:self];
}

#pragma mark - Private

- (ASIFormDataRequest *) requestWithURL:(NSURL *)anUrl
{
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL: anUrl];
    
    request.timeOutSeconds = 30;
    request.userAgentString = @"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:14.0) Gecko/20100101 Firefox/14.0.1";
    
    //add some parameters, common for all requests
    
    
    return request;
}

- (void) handleIncorrectResponse
{
    //TODO
}
@end
