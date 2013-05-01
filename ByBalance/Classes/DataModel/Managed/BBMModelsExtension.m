//
//  BBMModelsExtension.m
//  ByBalance
//
//  Created by Admin on 01.05.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBMModelsExtension.h"

@implementation BBMAccount (ByBalance)

- (NSString *) nameLabel
{
    if ([self.label length] > 0) return [NSString stringWithString:self.label];
    return [NSString stringWithString:self.username];
}

@end
