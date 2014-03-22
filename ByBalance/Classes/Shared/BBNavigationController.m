//
//  BBNavigationController.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/21/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBNavigationController.h"

@implementation BBNavigationController

- (NSUInteger)supportedInterfaceOrientations
{
    UIViewController *top = self.topViewController;
    return top.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate
{
    UIViewController *top = self.topViewController;
    return [top shouldAutorotate];
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // disable interactivePopGestureRecognizer in the rootViewController of navigationController
        if ([[navigationController.viewControllers firstObject] isEqual:viewController]) {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        } else {
            // enable interactivePopGestureRecognizer
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

@end
