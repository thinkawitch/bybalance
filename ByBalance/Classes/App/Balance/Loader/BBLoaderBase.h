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
@property (nonatomic,strong) AFHTTPClient * httpClient;

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
- (void) clearCookies:(NSString *)url;
- (void) setDefaultsForHttpClient;
- (void) extractInfoFromHtml:(NSString *)html;
- (void) doFinish;

//utils
- (NSDecimalNumber *) decimalNumberFromString:(id)value;

@end
