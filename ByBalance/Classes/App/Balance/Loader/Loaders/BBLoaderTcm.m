//
//  BBLoaderTcm.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 16.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderTcm.h"

@implementation BBLoaderTcm

#pragma mark - Logic

- (void) startLoader
{
    [self prepareHttpClient:@"https://tcm.by/"];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.account.username, @"login",
                             self.account.password, @"password",
                             nil];
    
    [self.httpClient POST:@"/info.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    
    if ([html isEqualToString:@"ERROR"] || [html isEqualToString:@"FORBIDDEN"])
    {
        self.loaderInfo.incorrectLogin = YES;
        return;
    }
    
    /*
     5081;2703034;226203;0;1;
     
     Где:
     5081 - номер лицевого счета
     2703034 - логин
     226203 - баланс, руб.
     0 - кредит, руб.
     1 - статус интернета (0 - ОТКЛ, 1 - ВКЛ)
     */
    
    NSArray *arr = [html componentsSeparatedByString:@";"];
    if (!arr || [arr count] < 3) return;
    
    NSString * bal = [arr objectAtIndex:2];
    if (![PRIMITIVE_HELPER stringIsNumeric:bal]) return;
    
    self.loaderInfo.userBalance = [NSDecimalNumber decimalNumberWithString:bal];
    
    //DDLogVerbose(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = YES;
}

@end
