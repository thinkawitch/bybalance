//
//  BBBaseViewController.h
//  ByBalance
//
//  Created by Lion User on 17/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface BBBaseViewController : UIViewController <UIAlertViewDelegate>
{
    
@protected
    // UI:
    
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
- (void) showWaitIndicator:(BOOL) anFlag;
- (void) setWaitTitle:(NSString *) newTitle;
//
- (void) setupNavBar;


@end
