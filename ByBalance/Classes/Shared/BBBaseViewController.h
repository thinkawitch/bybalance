//
//  BBBaseViewController.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

@class MBProgressHUD;

@interface BBBaseViewController : UIViewController <UIAlertViewDelegate>
{
    
@protected
    // UI:
    BOOL needUpdateScreen;
    
@private
    // Helper:
    MBProgressHUD * hud;
    
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
- (void) balanceCheckStarted:(NSNotification *)notification;
- (void) balanceCheckProgress:(NSNotification *)notification;
- (void) balanceChecked:(NSNotification *)notification;
- (void) balanceCheckStopped:(NSNotification *)notification;

@end
