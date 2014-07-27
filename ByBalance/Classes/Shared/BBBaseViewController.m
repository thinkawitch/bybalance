//
//  BBBaseViewController.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"
#import "MBProgressHUD.h"

@interface BBBaseViewController ()

@end


@implementation BBBaseViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self setupNavBar];
    
}

- (void) viewDidUnload
{
    [self cleanup];
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

#pragma mark - Autorotation

//iOS6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (APP_CONTEXT.isIpad) return UIInterfaceOrientationMaskAll;
    else return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - Actions
//
- (IBAction) onNavButtonLeft:(id)sender
{
	//to override
}

- (IBAction) onNavButtonRight:(id)sender
{
	//to override
}



#pragma mark - Core logic
//
- (void) cleanup
{
	// DO NOT FORGET CALL [SUPER CLEANUP] IF OVERRIDING ME!!
	
    //remove observers
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) showWaitIndicator:(BOOL) aFlag
{
	if (aFlag)
	{
        [self.view addSubview: hud];
        [hud show:YES];
	}
	else
	{
        if (hud.superview) [hud removeFromSuperview];
	}
    
    [self.tabBarController.tabBar setUserInteractionEnabled:!aFlag];
    [self.navigationController.navigationBar setUserInteractionEnabled:!aFlag];    
}

- (void) setWaitTitle:(NSString *) newTitle
{
    hud.labelText = newTitle;
}

#pragma mark - Setup

- (void) setupNavBar
{
    //navbar title
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) 
    {
        self.navigationItem.titleView = [APP_CONTEXT navBarLabel];
    }
}


#pragma mark - Notifications

- (void) accountsListUpdated:(NSNotification *)notification
{
    
}

- (void) balanceCheckStarted:(NSNotification *)notification
{
    //queue started
}

- (void) balanceCheckProgress:(NSNotification *)notification
{
    //queue request started
}

- (void) balanceChecked:(NSNotification *)notification
{
    //queue request processed
}

- (void) balanceCheckStopped:(NSNotification *)notification
{
    //queue stopped
}

- (UIViewController *) backViewController
{
    NSArray * stack = self.navigationController.viewControllers;
    
    for (NSInteger i=stack.count-1; i > 0; --i)
        if (stack[i] == self)
            return stack[i-1];
    
    return nil;
}


@end
