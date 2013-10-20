//
//  RotationAwareNavigationController.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/21/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "RotationAwareNavigationController.h"

@implementation RotationAwareNavigationController

-(NSUInteger)supportedInterfaceOrientations {
    UIViewController *top = self.topViewController;
    return top.supportedInterfaceOrientations;
}

-(BOOL)shouldAutorotate {
    UIViewController *top = self.topViewController;
    return [top shouldAutorotate];
}

@end
