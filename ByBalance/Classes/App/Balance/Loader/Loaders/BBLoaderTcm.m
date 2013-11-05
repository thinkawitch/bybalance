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
    [self clearCookies:@"https://tcm.by/"];
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://tcm.by/"]];
    [self setDefaultsForHttpClient];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.account.username, @"login",
                             self.account.password, @"password",
                             nil];
    
    [self.httpClient postPath:@"/info.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self extractInfoFromHtml:text];
        [self doFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self doFinish];
    }];
}

- (void) extractInfoFromHtml:(NSString *)html
{
    //NSLog(@"%@", html);
    
    if (!html)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
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
    if (!arr || [arr count] <3)
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSString * bal = [arr objectAtIndex:2];
    if (![PRIMITIVE_HELPER stringIsNumeric:bal])
    {
        self.loaderInfo.extracted = NO;
        return;
    }
    
    NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:bal];
    self.loaderInfo.userBalance = num;
    
    //NSLog(@"balance: %@", loaderInfo.userBalance);
    
    self.loaderInfo.extracted = YES;
}

@end
