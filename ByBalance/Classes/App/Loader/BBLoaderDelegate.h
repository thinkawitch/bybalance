//
//  BBLoaderDelegate.h
//  ByBalance
//
//  Created by Lion User on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBLoaderBase;

@protocol BBLoaderDelegate <NSObject>

@required
- (void) dataLoaderSuccess:(BBLoaderBase*)loader;
- (void) dataLoaderFail:(BBLoaderBase*)loader;
@end

