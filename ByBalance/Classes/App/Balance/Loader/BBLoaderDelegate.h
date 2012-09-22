//
//  BBLoaderDelegate.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBLoaderBase;

@protocol BBLoaderDelegate <NSObject>

@required
- (void) balanceLoaderSuccess:(NSDictionary *)info;
- (void) balanceLoaderFail:(NSDictionary *)info;
@end

