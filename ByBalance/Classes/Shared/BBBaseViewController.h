//
//  BBBaseViewController.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

@interface BBBaseViewController : UIViewController <UIAlertViewDelegate>
{
    
@protected
    // UI:
    BOOL needUpdateScreen;
    
@private
    // Helper:
    DSActivityView		* waitIndicator;
    
}

//
- (void) cleanup;
//
- (IBAction) onNavButtonLeft:(id)sender;
- (IBAction) onNavButtonRight:(id)sender;
//
- (void) showWaitIndicator:(BOOL) aFlag;
- (void) setWaitTitle:(NSString *) newTitle;
//
- (void) setupNavBar;
//
- (void) accountsListUpdated:(NSNotification *)notification;

@end
