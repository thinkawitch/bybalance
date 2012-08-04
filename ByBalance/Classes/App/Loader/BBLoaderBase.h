//
//  BBLoaderBase.h
//  ByBalance
//
//  Created by Lion User on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"

@interface BBLoaderBase : NSObject <ASIHTTPRequestDelegate>
{
@protected
    BBBaseItem * item;
    id <BBLoaderDelegate> delegate;
}

@property (nonatomic,retain) BBBaseItem * item;
@property (nonatomic,assign) id <BBLoaderDelegate> delegate;

- (void) start;

- (void) login;
- (void) getDetails;

@end
