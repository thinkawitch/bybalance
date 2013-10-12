//
//  BBAppDelegate.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/12/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBViewController;

@interface BBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet BBViewController *viewController;

@end
