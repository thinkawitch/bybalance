//
//  BBBasesManager.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 29/11/14.
//  Copyright (c) 2014 sinkevitch.name. All rights reserved.
//


@interface BBBasesManager : NSObject
{
}

+ (BBBasesManager *) sharedBBBasesManager;

- (void) updateWithCallback:(void(^)(BOOL,NSString*))callback;

@end
