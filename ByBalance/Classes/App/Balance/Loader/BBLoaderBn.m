//
//  BBLoaderBn.m
//  ByBalance
//
//  Created by Admin on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderBn.h"

@implementation BBLoaderBn

- (ASIFormDataRequest *) prepareRequest
{
    NSString * loginUrl = @"http://ui.bn.by/index.php?mode=login";
    
    NSURL * url = [NSURL URLWithString:loginUrl];
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    [request addRequestHeader:@"Referer" value:loginUrl];
    [request setPostValue:account.username forKey:@"login"];
    [request setPostValue:account.password forKey:@"passwd"];
    
    request.delegate = self;
    
    return request;
}

@end
