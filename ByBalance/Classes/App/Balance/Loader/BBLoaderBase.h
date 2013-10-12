//
//  BBLoaderBase.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ASIHTTPRequestDelegate.h"
//#import "ASIFormDataRequest.h"
#import "BBAsiTemp.h"

@interface BBLoaderBase : NSOperation <ASIHTTPRequestDelegate>
{
    BOOL loaderExecuting;
    BOOL loaderFinished;
}

@property (nonatomic,strong) BBMAccount * account;
@property (nonatomic,strong) BBLoaderInfo * loaderInfo;
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
- (ASIFormDataRequest *) requestWithURL:(NSURL *)url;
- (ASIFormDataRequest *) prepareRequest;

//
- (BOOL) isAFNetworking;
- (void) startAFNetworking;

//
- (void) extractInfoFromHtml:(NSString *)html;
- (void) doFinish;
@end
