//
//  BBBaseViewController.m
//  ByBalance
//
//  Created by Lion User on 17/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBBaseViewController.h"


@interface BBBaseViewController ()

@end


@implementation BBBaseViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	waitIndicator = (DSBezelActivityView *) [[DSBezelActivityView alloc] initForViewAsInstance:self.view withLabel:@"" width:1];
    
    [self setupNavBar];
}

- (void) viewDidUnload
{
    [self cleanup];
    
    [super viewDidUnload];
}

- (void) dealloc
{
	[self cleanup];
	
	[super dealloc];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
	
	if (waitIndicator)
	{
		[self showWaitIndicator: NO];
		[waitIndicator release];
		waitIndicator = nil;
	}
}

- (void) showWaitIndicator:(BOOL) aFlag
{
	if (aFlag)
	{
		waitIndicator.activityLabel.text = @"";
		
		[self.view addSubview: waitIndicator]; 
		[waitIndicator animateShow];
	}
	else
	{
		if (waitIndicator.superview) [waitIndicator removeFromSuperview];
	}
    
    [self.tabBarController.tabBar setUserInteractionEnabled:!aFlag];
    [self.navigationController.navigationBar setUserInteractionEnabled:!aFlag];    
}

- (void) setWaitTitle:(NSString *) newTitle
{
	waitIndicator.activityLabel.text = newTitle;
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

#pragma mark - NSObject
//
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@. retainCount = %d", [self class], self.retainCount];
}

@end
