//
//  BBItemCosmosTV.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 23.03.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBItemCosmosTV.h"

@implementation BBItemCosmosTV

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
    if (!html)
    {
        self.extracted = NO;
        return;
    }
    
    NSString * jsonString = [NSString stringWithFormat:@"%@", html];
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    
    if (![jsonObject isKindOfClass:[NSDictionary class]])
    {
        //это не json
        self.extracted = NO;
        return;
    }
    
    NSDictionary * dict = (NSDictionary *) jsonObject;
    NSArray * services = [dict objectForKey:@"services"];
    if (!services || [services count] < 1)
    {
        self.extracted = NO;
        return;
    }
    
    NSDictionary * service1 = [services objectAtIndex:0];
    if (![service1 isKindOfClass:[NSDictionary class]])
    {
        self.extracted = NO;
        return;
    }
    
    NSString * pbalance = [service1 objectForKey:@"pbalance"];
    if (!pbalance)
    {
        self.extracted = NO;
        return;
    }
    
    NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:pbalance];
    self.userBalance = [NSString stringWithFormat:@"%d", [num integerValue]];
    
    self.extracted = [userBalance length] > 0;
}

- (NSString *) fullDescription
{
    if (extracted)
    {
        return [NSString stringWithFormat:@"%@\r\n%@", username, userBalance];
    }
    else
    {
        return [NSString stringWithFormat:@"данные от Космос ТВ по %@ не получены", username];
    }
}

@end
