//
//  BBLoaderByFly.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderByFly.h"

@interface BBLoaderByFly ()

//@property (strong, readwrite) NSMutableData * receivedData;

@end

@implementation BBLoaderByFly

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL * url = [NSURL URLWithString:@"https://issa.beltelecom.by/cgi-bin/cgi.exe?function=is_login"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    //[request setShouldAttemptPersistentConnection:NO];
    [request setShouldCompressRequestBody:NO];
    [request setAllowCompressedResponse:NO];
    //[request setValidatesSecureCertificate:NO];
    
    //[request setPostFormat:ASIMultipartFormDataPostFormat];
    //[request setRequestMethod:@"POST"];
    //[request addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    //[request addRequestHeader:@"Accept-Language" value:@"en-US,en;q=0.5"];
    //[request addRequestHeader:@"Cache-Control" value:@"max-age:0"];
    //[request addRequestHeader:@"Connection" value:@"keep-alive"];
    
    //[request addRequestHeader:@"Host" value:@"issa.beltelecom.by"];
    
    //[request setPostValue:@"2" forKey:@"Lang"];
    
    [request setPostValue:account.username forKey:@"mobnum"];
    [request setPostValue:account.password forKey:@"Password"];
    
    //[request appendPostData:[@"mobnum=1760003226601&Password=2308039" dataUsingEncoding:NSUTF8StringEncoding]];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    //[request setRequestMethod:@"POST"];
    

    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestStarted", [self class]);
    NSLog(@"url: %@", request.url);
    NSLog(@"requestMethod: %@", request.requestMethod);
    
    
    for (NSString * name in request.requestHeaders)
    {
        NSLog(@"[header] %@: %@", name, [request.requestHeaders objectForKey:name]);
    }
    
    for (NSString * name in request.requestCookies)
    {
        NSLog(@"[cookie] %@", name);
    }
    
    NSLog(@"[body] %@", [[NSString alloc] initWithData:request.postBody encoding:NSUTF8StringEncoding]);
    
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFinished", [self class]);
    NSLog(@"%@", request.responseString);
    
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

/*

@interface BBLoaderByFly ()

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;

- (void) doFail;
- (void) doSuccess:(NSString *)html;

@end

@implementation BBLoaderByFly


#pragma mark - ObjectLife

- (void) dealloc
{
    [super dealloc];
}

- (ASIFormDataRequest *) prepareRequest
{
    //don't use other cookies
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL * url = [NSURL URLWithString:@"http://www.byfly.by/"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Host" value:@"www.byfly.by"];
    [request addRequestHeader:@"Referer" value:@"http://www.byfly.by/"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    return request;
}


#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestStarted", [self class]);
    NSLog(@"url: %@", request.url);
    
    
    for (NSString * name in request.requestHeaders)
    {
        NSLog(@"[header] %@: %@", name, [request.requestHeaders objectForKey:name]);
    }

    for (NSString * name in request.requestCookies)
    {
        NSLog(@"[cookie] %@", name);
    }
    
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFinished", [self class]);
    
    NSString * step = [request.userInfo objectForKey:@"step"];
    NSString * html = request.responseString;
    
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
        [self doFail];
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@.requestFailed" , [self class]);
    NSLog(@"%@", [request error]);
    
    [self doFail];
}


#pragma mark - Logic

- (void) onStep1:(NSString *)html
{
    NSLog(@"BBLoaderByFly.onStep1");
    //NSLog(@"%@", html);
    
    NSString * loginUrl = @"https://issa.beltelecom.by/cgi-bin/cgi.exe?function=is_login";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    //[request addRequestHeader:@"Referer" value:@"http://www.byfly.by/"];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"2" forKey:@"Lang"];
    [request setPostValue:account.username forKey:@"mobnum"];
    [request setPostValue:account.password forKey:@"Password"];
    
    //[request setShouldUseRFC2616RedirectBehaviour:YES];
    //[request setShouldRedirect:NO];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    //start request
    [request startAsynchronous];
}

- (void) onStep2:(NSString *)html
{
    NSLog(@"BBLoaderByFly.onStep2");
    //NSLog(@"%@", html);
    
    [self doSuccess:html];
}

- (void) doFail
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderFail:)])
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, nil]];
        
        [self.delegate balanceLoaderFail:info];
    }
    
    [self markDone];
}

- (void) doSuccess:(NSString *)html
{
    if ([self.delegate respondsToSelector:@selector(balanceLoaderSuccess:)])
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account, html, nil]
                                                          forKeys:[NSArray arrayWithObjects:kDictKeyAccount, kDictKeyHtml, nil]];
        
        [self.delegate balanceLoaderSuccess:info];
    }
    
    [self markDone];
}

@end
*/