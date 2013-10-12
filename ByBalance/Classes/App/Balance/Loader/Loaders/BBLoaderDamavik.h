//
//  BBLoaderDamavik.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.01.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBLoaderBase.h"

@interface BBLoaderDamavik : BBLoaderBase
{
    BOOL isDamavik;
    BOOL isAtlant;
}

- (void) actAsDamavik;
- (void) actAsAtlantTelecom;

@end
