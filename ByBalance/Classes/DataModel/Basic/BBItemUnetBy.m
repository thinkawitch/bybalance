//
//  BBItemUnetBy.m
//  ByBalance
//
//  Created by Admin on 14.07.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemUnetBy.h"
#import "XMLReader.h"

@implementation BBItemUnetBy


#pragma mark - Logic

- (void) extractFromHtml:(NSString *)html
{
    NSLog(@"%@", html);
    if (!html)
    {
        self.extracted = NO;
        return;
    }
    
    NSError * error = nil;
    NSDictionary * dict = [XMLReader dictionaryForXMLString:html
                                                    options:XMLReaderOptionsProcessNamespaces
                                                      error:&error];
    
    //NSLog(@"%@", dict);
    if (error || !dict)
    {
        self.extracted = NO;
        return;
    }
    
    
    NSDictionary * nodeResp = [dict objectForKey:@"res"];
    if (!nodeResp)
    {
        self.extracted = NO;
        return;
    }
    
    NSDictionary * nodeTag = [nodeResp objectForKey:@"tag"];
    if (!nodeTag)
    {
        self.extracted = NO;
        return;
    }
    
    NSDictionary * nodeDeposit = [nodeTag objectForKey:@"deposit"];
    if (!nodeDeposit)
    {
        self.extracted = NO;
        return;
    }
    
    NSString * textBalance = [nodeDeposit objectForKey:@"text"];
    if (!textBalance)
    {
        self.extracted = NO;
        return;
    }
    
    self.userBalance = textBalance;
    NSLog(@"balance: %@", userBalance);
    
    self.extracted = YES;
}

- (NSString *) fullDescription
{
    if (extracted)
    {
        return [NSString stringWithFormat:@"%@\r\n%@", username, userBalance];
    }
    else
    {
        return [NSString stringWithFormat:@"данные от UNET.BY по %@ не получены", username];
    }
}

@end
