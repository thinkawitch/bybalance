//
//  BBLoaderVelcom.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderVelcom.h"

@interface BBLoaderVelcom ()

@property (nonatomic,strong) NSString * sessionId;

- (void) onStep1:(NSString *)html;
- (void) onStep2:(NSString *)html;
- (void) onStep3:(NSString *)html;

@end


@implementation BBLoaderVelcom

@synthesize sessionId;

#pragma mark - Logic

- (void) startLoader
{
    [self clearCookies:@"https://internet.velcom.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://internet.velcom.by/"]];
    [self setDefaultsForHttpClient];
    
    [self.httpClient getPath:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self onStep1:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

- (void) onStep1:(NSString *)html
{
    //NSLog(@"BBLoaderVelcom.onStep1");
    //NSLog(@"%@", html);
    
    NSString * buf = nil;
    NSArray * arr = nil;
    
    //try to detect session
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"name=\"sid3\" value=\"([^\"]+)\"" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.sessionId = buf;
        }
    }
    
    //NSLog(@"sessionId: %@", self.sessionId);
    
    if (!self.sessionId)
    {
        [self doFinish];
        return;
    }
    /*
    NSURL * url = [NSURL URLWithString:@"https://internet.velcom.by/work.html"];
    ASIFormDataRequest * request = [self requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request addRequestHeader:@"Host" value:@"internet.velcom.by"];
    [request addRequestHeader:@"Referer" value:@"https://internet.velcom.by/"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"step", nil]];
    
    NSNumber * ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSString * s1 = [account.username substringToIndex:2];
    NSString * s2 = [account.username substringFromIndex:2];
    
    [request setPostValue:self.sessionId forKey:@"sid3"];
    [request setPostValue:ts forKey:@"user_input_timestamp"];
    [request setPostValue:@"_next" forKey:@"user_input_0"];
    [request setPostValue:@"" forKey:@"last_id"];
    [request setPostValue:@"5" forKey:@"user_input_8"];
    
    [request setPostValue:s1 forKey:@"user_input_1"];
    [request setPostValue:s2 forKey:@"user_input_2"];
    [request setPostValue:account.password forKey:@"user_input_3"];    
    [request setPostValue:@"2" forKey:@"user_input_9"];
    [request setPostValue:@"0" forKey:@"user_input_10"];
    
    //start request
    [request startAsynchronous];
     */
    
    NSNumber * ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    NSString * s1 = [self.account.username substringToIndex:2];
    NSString * s2 = [self.account.username substringFromIndex:2];
    
    
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.sessionId, @"sid3",
                             ts, @"user_input_timestamp",
                             @"_next", @"user_input_0",
                             @"", @"last_id",
                             @"5", @"user_input_8",
                             s1, @"user_input_1",
                             s2, @"user_input_2",
                             self.account.password, @"user_input_3",
                             @"2", @"user_input_9",
                             @"0", @"user_input_10",
                             nil];
    
    //NSMutableURLRequest *request = [self.httpClient multipartFormRequestWithMethod:@"POST" path:@"/work.html" parameters:params constructingBodyWithBlock: nil];
    
    NSMutableURLRequest *request = [self.httpClient multipartFormRequestWithMethod:@"POST" path:@"/work.html" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFormData:[self.sessionId dataUsingEncoding:NSUTF8StringEncoding] name:@"sid3"];
        [formData appendPartWithFormData:[[ts stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_timestamp"];
        [formData appendPartWithFormData:[@"_next" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_0"];
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"last_id"];
        [formData appendPartWithFormData:[@"5" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_8"];
        [formData appendPartWithFormData:[s1 dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_1"];
        [formData appendPartWithFormData:[s2 dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_2"];
        [formData appendPartWithFormData:[self.account.password dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_3"];
        [formData appendPartWithFormData:[@"2" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_9"];
        [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_10"];
    }];

    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

         [self onStep2:operation.responseString];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self doFinish];
     }];
    
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

- (void) onStep2:(NSString *)html
{
    //NSLog(@"BBLoaderVelcom.onStep2");
    //NSLog(@"%@", html);
    
    NSString * menuMarker = @"";
    NSString * menuMarker1 = @"_root/USER_INFO";
    NSString * menuMarker2 = @"_root/MENU0";
    
    BOOL loggedIn = false;
    //check if we logged in
    if ([html rangeOfString:menuMarker1].location != NSNotFound)
    {
        menuMarker = menuMarker1;
        loggedIn = YES;
    }
    else if ([html rangeOfString:menuMarker2].location != NSNotFound)
    {
        menuMarker = menuMarker2;
        loggedIn = YES;
    }

    if (!loggedIn)
    {
        //maybe login problem
        self.loaderInfo.incorrectLogin = YES;
        [self doFinish];
        return;
    }
    
    NSNumber * ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSMutableURLRequest *request = [self.httpClient multipartFormRequestWithMethod:@"POST" path:@"/work.html" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFormData:[self.sessionId dataUsingEncoding:NSUTF8StringEncoding] name:@"sid3"];
        [formData appendPartWithFormData:[[ts stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_timestamp"];
        [formData appendPartWithFormData:[menuMarker dataUsingEncoding:NSUTF8StringEncoding] name:@"user_input_0"];
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"last_id"];
    }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

         [self onStep3:operation.responseString];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [self doFinish];
     }];
    
    [self.httpClient enqueueHTTPRequestOperation:operation];
}


- (void) onStep3:(NSString *)html
{
    //NSLog(@"BBLoaderVelcom.onStep3");
    //NSLog(@"%@", html);
    
    [self extractInfoFromHtml:html];
    [self doFinish];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    NSString * buf = nil;
    NSArray * arr = nil;
    
    NSString * menuMarker = @"";
    NSString * menuMarker1 = @"_root/USER_INFO";
    NSString * menuMarker2 = @"_root/MENU0";
    
    BOOL loggedIn = false;
    //check if we logged in
    if ([html rangeOfString:menuMarker1].location != NSNotFound)
    {
        menuMarker = menuMarker1;
        loggedIn = YES;
    }
    else if ([html rangeOfString:menuMarker2].location != NSNotFound)
    {
        menuMarker = menuMarker2;
        loggedIn = YES;
    }
    
    if (!loggedIn)
    {
        //incorrect login/pass
        self.loaderInfo.incorrectLogin = ([html rangeOfString:@"INFO_Error_caption"].location != NSNotFound);
        //NSLog(@"incorrectLogin: %d", incorrectLogin);
        
        if (self.loaderInfo.incorrectLogin)
        {
            self.loaderInfo.extracted = NO;
            return;
        }
    }
    
    
    //userTitle
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"ФИО:</td><td class=\"INFO\">([^<]+)</td>" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userTitle = buf;
        }
    }
    //NSLog(@"userTitle: %@", loaderInfo.userTitle);
    
    //userPlan
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Тарифный план:\\s*</td><td class=\"INFO\"[^>]*>([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userPlan = buf;
        }
    }
    //NSLog(@"userPlan: %@", loaderInfo.userPlan);
    
    //balance 1
    arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Текущий баланс:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
    if (arr && [arr count] == 1)
    {
        buf = [arr objectAtIndex:0];
        if (nil != buf && [buf length] > 0)
        {
            self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    
    if (!self.loaderInfo.userBalance || [self.loaderInfo.userBalance length] < 1)
    {
        //balance 2
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Баланс:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            buf = [arr objectAtIndex:0];
            if (nil != buf && [buf length] > 0)
            {
                self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        }
    }
    
    if (!self.loaderInfo.userBalance || [self.loaderInfo.userBalance length] < 1)
    {
        //balance 3
        arr = [html stringsByExtractingGroupsUsingRegexPattern:@"Начисления\\s*абонента\\*:</td><td class=\"INFO\">([^<]+)" caseInsensitive:YES treatAsOneLine:NO];
        if (arr && [arr count] == 1)
        {
            buf = [arr objectAtIndex:0];
            if (nil != buf && [buf length] > 0)
            {
                self.loaderInfo.userBalance = [buf stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        }
    }
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = [self.loaderInfo.userPlan length] > 0 && [self.loaderInfo.userBalance length] > 0;
}

@end
