//
//  BBLoaderByFly.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderByFly.h"
#import "AFNetworking.h"

@interface BBLoaderByFly ()

@property (strong, readwrite) AFHTTPClient * httpClient;

- (void) doFail;
- (void) doSuccess:(NSString *)html;

@end

@implementation BBLoaderByFly

#pragma mark - ObjectLife

- (void) dealloc
{
    self.httpClient = nil;
    
    [super dealloc];
}


- (BOOL) isAFNetworking
{
    return YES;
}


- (void) startAFNetworking
{
    NSURL *url = [NSURL URLWithString:@"https://issa.beltelecom.by/"];
    
    self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            account.username, @"mobnum",
                            account.password, @"Password",
                            nil];
    
    [self.httpClient postPath:@"/cgi-bin/cgi.exe?function=is_login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response1 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
        NSLog(@"Response1:\n%@", response1);
        
        //cgi.exe?function=is_account
        if ([response1 rangeOfString:@"cgi.exe?function=is_account"].location == NSNotFound)
        {
            [self doFail];
        }
        else
        {
            [self.httpClient getPath:@"/cgi-bin/cgi.exe?function=is_login" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *response2 = [[NSString alloc] initWithData:responseObject encoding:NSWindowsCP1251StringEncoding];
                NSLog(@"Response2:\n%@", response2);
                
                [self doSuccess:response2];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self doFail];
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [self doFail];
    }];
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
