//
//  BBBaseItem.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 22/07/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBBaseItem : NSObject
{
    
@protected
    NSString * username;
    NSString * password;
    //
    BOOL isBanned;
    BOOL isExtracted;
    NSString * userTitle;
    NSString * userPlan;
    NSString * userBalance;
}

@property (nonatomic,retain) NSString * username;
@property (nonatomic,retain) NSString * password;
//
@property (nonatomic,assign) BOOL isBanned;
@property (nonatomic,assign) BOOL isExtracted;
@property (nonatomic,retain) NSString * userTitle;
@property (nonatomic,retain) NSString * userPlan;
@property (nonatomic,retain) NSString * userBalance;

- (void) extractFromHtml:(NSString *)html;
- (NSString *) fullDescription;

@end
