//
//  BBItemInfolan.m
//  ByBalance
//
//  Created by Admin on 02.06.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemInfolan.h"
#import "XMLReader.h"

@implementation BBItemInfolan

#pragma mark - ObjectLife

- (id) init
{
	self = [super init];
	if (self)
	{
        //
	}
	
	return self;
}

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
    
    
    //correct response
    NSDictionary * nodeResp = [dict objectForKey:@"Response"];
    if (!nodeResp)
    {
        self.extracted = NO;
        return;
    }
    
    //NSLog(@"%@", nodeResp);
    
    //has error
    if ([nodeResp objectForKey:@"Error"])
    {
        self.extracted = NO;
        return;
    }
    
    NSDictionary * nodeMain = [nodeResp objectForKey:@"Main"];
    if (!nodeMain)
    {
        self.extracted = NO;
        return;
    }
    
    NSDictionary  * nodeBalance = [nodeMain objectForKey:@"Balance"];
    if (!nodeBalance)
    {
        self.extracted = NO;
        return;
    }
    
    NSString  * textBalance = [nodeBalance objectForKey:@"text"];
    if (!textBalance)
    {
        self.extracted = NO;
        return;
    }
    
    //NSLog(@"%@", textBalance);
    
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
        return [NSString stringWithFormat:@"данные от Infolan по %@ не получены", username];
    }
}

@end
