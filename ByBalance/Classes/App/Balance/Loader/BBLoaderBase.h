//
//  BBLoaderBase.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"

@interface BBLoaderBase : NSOperation <ASIHTTPRequestDelegate>
{
@protected
    BBMAccount * account;
    id <BBLoaderDelegate> delegate;
    
    BOOL loaderExecuting;
    BOOL loaderFinished;
}

@property (nonatomic,retain) BBMAccount * account;
@property (nonatomic,assign) id <BBLoaderDelegate> delegate;


// NSOperation
- (void) start;
- (BOOL) isConcurrent;
- (BOOL) isExecuting;
- (BOOL) isFinished;
//
- (void) markStart;
- (void) markStop;
- (void) markDone;

//
- (ASIFormDataRequest *) requestWithURL:(NSURL *)anUrl;
- (ASIFormDataRequest *) prepareRequest;

//
- (BOOL) isAFNetworking;
- (void) startAFNetworking;
@end
