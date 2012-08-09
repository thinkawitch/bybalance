//
//  AppContext.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class Reachability;

@interface AppContext : NSObject
{
    
@private
    
    //
	// Reachability:
    BOOL				isOnline;
	Reachability		* reachability;
}

@property (nonatomic, readwrite, assign) BOOL isOnline;

+ (AppContext *) sharedAppContext;

//
- (void) startContext;
- (void) stopContext;
//
- (void) setupDatabase;
- (void) saveDatabase;

// Helper - navigation bar:
- (UIBarButtonItem *) backButton;
- (UIBarButtonItem *) menuButton;
- (UIBarButtonItem *) infoIconButton;
- (UIBarButtonItem *) addIconButton;
- (UIBarButtonItem *) buttonFromName:(NSString *) resourceName;
- (UIBarButtonItem *) buttonWithTitle:(NSString *) anTitle;
- (UIImage *) stretchedImageNamed:(NSString *) anName width:(CGRect)anRect;
- (UILabel *) navBarLabel;

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


