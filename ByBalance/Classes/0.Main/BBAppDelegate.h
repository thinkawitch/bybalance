//
//  BBAppDelegate.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBHomeViewController;

@interface BBAppDelegate : UIResponder <UIApplicationDelegate>
{
    //
}

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) BBHomeViewController * viewController;

@end
