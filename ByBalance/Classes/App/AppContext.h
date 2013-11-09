//
//  AppContext.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

@class Reachability;

@interface AppContext : NSObject
{
    
@private
    //
	// Reachability:
    BOOL isOnline;
    BOOL isOnlineWifi;
    BOOL isOnlineCellular;
	Reachability * reachability;
    //
    BOOL doBgFetch;
}

@property (nonatomic, assign) BOOL doBgFetch;

+ (AppContext *) sharedAppContext;

//
- (void) start;
- (void) stop;
//
- (BOOL) isOnline;
- (BOOL) isOnlineWifi;
- (BOOL) isOnlineCellular;
//
- (void) saveDatabase;
- (void) showAllAccounts;
//

// Helper - navigation bar:
- (UIBarButtonItem *) backButton;
- (UIBarButtonItem *) buttonFromName:(NSString *) resourceName;
- (UILabel *) navBarLabel;
- (UILabel *) toolBarLabel;

// Styles
- (void) makeRedButton:(UIButton *) button;

// UIAlertView variations:
- (void) showAlertForNoInternet;
- (void) showAlertWithTitle:(NSString *) anTitle andText:(NSString *) anText;
- (void) showAlertWithTitle:(NSString *) anTitle andText:(NSString *) anText andDelegate:(id<UIAlertViewDelegate>) anDelegate andButtonsTitles:(NSArray *) arrButtonsTitles;
- (void) showAlertFromError:(NSError *) error;
//
- (void) showToastWithText:(NSString *)aText;

//
- (NSString *) basePath;

@end


