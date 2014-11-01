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
	// reachability:
    BOOL isOnline;
    BOOL isOnlineWifi;
    BOOL isOnlineCellular;
	Reachability * reachability;
    
    //
    BOOL iOs7;
    BOOL iOs8;
    BOOL iPhone;
    BOOL iPad;
}



+ (AppContext *) sharedAppContext;

//
- (void) start;
- (void) stop;
//
- (void) startReachability;
- (void) stopReachability;
- (BOOL) isOnline;
- (BOOL) isOnlineWifi;
- (BOOL) isOnlineCellular;
//
- (BOOL) isIos7;
- (BOOL) isIos8;
- (BOOL) isIphone;
- (BOOL) isIpad;
//
- (void) saveDatabase;
- (void) showAllAccounts;
- (void) clearAllHistory;
//

// Helper - navigation bar:
- (UIBarButtonItem *) backButton;
- (UIBarButtonItem *) buttonFromName:(NSString *) resourceName;
- (UILabel *) navBarLabel;
- (UILabel *) toolBarLabel;

// Styles
- (UIColor *) colorRed;
- (UIColor *) colorGrayLight;
- (UIColor *) colorGrayMedium;
- (UIColor *) colorGrayDark;
- (UIColor *) colorBg;
- (UIImage *) imageColored:(NSString *)resourceName;
- (void) makeRedButton:(UIButton *) button;
- (CGFloat) labelTextWidth:(UILabel *)label;
- (UIView *)circleWithColor:(UIColor *)color radius:(int)radius;
- (void) makeRedCircle:(UIView *)circle;

// UIAlertView variations:
- (void) showAlertForNoInternet;
- (void) showAlertWithTitle:(NSString *) anTitle andText:(NSString *) anText;
- (void) showAlertWithTitle:(NSString *) anTitle andText:(NSString *) anText andDelegate:(id<UIAlertViewDelegate>) anDelegate andButtonsTitles:(NSArray *) arrButtonsTitles;
- (void) showAlertFromError:(NSError *) error;
//
- (void) showToastWithText:(NSString *)aText;

//
- (NSString *) basePath;
//
- (NSString *) formatWordAccount:(NSInteger)num;
- (NSString *) formatWordCrossed:(NSInteger)num;


@property (nonatomic, strong) UIPopoverController *masterPC;

@end


