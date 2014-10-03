//
//  BBLoaderInfolan.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 02.06.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderInfolan.h"

@implementation BBLoaderInfolan


#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"http://balance.infolan.by/"];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.account.username, @"id",
                             self.account.password, @"auth",
                             nil];
    
    [self.httpClient POST:@"/balance_by.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self extractInfoFromHtml:text];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"%@ httpclient_error: %@", [self class], error.localizedDescription);
        [self doFinish];
    }];
    
}

- (void) extractInfoFromHtml:(NSString *)html
{
    //DDLogVerbose(@"%@", html);
    
    if (!html) return;
    
    NSError * error = nil;
    NSDictionary * dict = [XMLReader dictionaryForXMLString:html
                                                    options:XMLReaderOptionsProcessNamespaces
                                                      error:&error];
    
    //DDLogVerbose(@"%@", dict);
    if (error || !dict) return;
    
    
    //correct response
    NSDictionary * nodeResp = [dict objectForKey:@"Response"];
    if (!nodeResp) return;
    
    //DDLogVerbose(@"%@", nodeResp);
    
    //has error
    if ([nodeResp objectForKey:@"Error"]) return;
    
    NSDictionary * nodeMain = [nodeResp objectForKey:@"Main"];
    if (!nodeMain) return;
    
    NSDictionary  * nodeBalance = [nodeMain objectForKey:@"Balance"];
    if (!nodeBalance) return;
    
    NSString  * textBalance = [nodeBalance objectForKey:@"text"];
    if (!textBalance) return;
    
    self.loaderInfo.userBalance = [NSDecimalNumber decimalNumberWithString:textBalance];
    
    //DDLogVerbose(@"%@", textBalance);
    //DDLogVerbose(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = YES;
}

@end
