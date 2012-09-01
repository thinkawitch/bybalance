//
//  BBBalanceChecker.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "ASIHTTPRequestDelegate.h"

@class BBMAccount;

@interface BBBalanceChecker : NSObject <ASIHTTPRequestDelegate>
{
    
@private
    
    BOOL isBusy;
    NSObject * syncFlag1;
    NSObject * syncFlag2;
    NSObject * syncFlag3;
    NSOperationQueue * queue;
}

+ (BBBalanceChecker *) sharedBBBalanceChecker;

//
- (void) start;
- (BOOL) isBusy;
- (void) stop;
//

- (void) addItem:(BBMAccount *) item;



@end
