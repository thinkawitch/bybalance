//
//  BBLoaderBase.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBLoaderBase : NSOperation
{
    BOOL loaderExecuting;
    BOOL loaderFinished;
}

@property (nonatomic,strong) BBMAccount * account;
@property (nonatomic,strong) BBLoaderInfo * loaderInfo;
@property (nonatomic,assign) id <BBLoaderDelegate> delegate;
@property (nonatomic,strong) AFHTTPRequestOperationManager * httpClient;

// NSOperation
- (void) start;
- (BOOL) isConcurrent;
- (BOOL) isExecuting;
- (BOOL) isFinished;
//
- (void) markStart;
- (void) markStop;
- (void) markDone;

// BalanceLoader
- (void) startLoader;
- (void) showCookies:(NSString *)url;
- (void) clearCookies:(NSString *)url;
- (void) prepareHttpClient:(NSString *)url;
- (void) extractInfoFromHtml:(NSString *)html;
- (void) doFinish;

//utils
- (NSDecimalNumber *) decimalNumberFromString:(id)value;

@end
