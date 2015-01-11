//
//  AppContext.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppContext.h"
#import "Reachability.h"
#import "iToast.h"
#import "UIImage+Color.h"

@interface AppContext ()
- (void) setupDatabase;
- (void) reachabilityChanged:(NSNotification *)note;
- (NSString *) numEnding:(NSInteger)num inArr:(NSArray *)arr;
@end

@implementation AppContext

SYNTHESIZE_SINGLETON_FOR_CLASS(AppContext, sharedAppContext);

#pragma mark - Public

- (void) start
{
    //internet connection reachability
    isOnline = NO;
    isOnlineWifi = NO;
    isOnlineCellular = NO;
    
    //
    [self setupDatabase];
    
    //
    iToastSettings * ts = [iToastSettings getSharedSettings];
    ts.duration = 3000;
    ts.useShadow = NO;
    
    //
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    iOs8 = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"));
    iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    iPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (void) stop
{
    [self stopReachability];
    
    [self saveDatabase];
    [MagicalRecord cleanUp];
}

#pragma mark - Reachability

- (void) startReachability
{
    [self stopReachability];
    
    //DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
	[reachability startNotifier];
}

- (void) startBgReachability
{
    
}

- (void) stopReachability
{
    //DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    if (reachability)
    {
        [reachability stopNotifier];
        reachability = nil;
    }
    
    isOnline = NO;
    isOnlineWifi = NO;
    isOnlineCellular = NO;
}

- (BOOL) isOnline
{
    return isOnline;
}

- (BOOL) isOnlineWifi
{
    return isOnlineWifi;
}

- (BOOL) isOnlineCellular
{
    return isOnlineCellular;
}

- (void) reachabilityChanged:(NSNotification *)note
{
    NetworkStatus ns = [reachability currentReachabilityStatus];
    if (ns == NotReachable)
    {
        isOnline = NO;
        isOnlineWifi = NO;
        isOnlineCellular = NO;
    }
    else
    {
        isOnline = YES;
        isOnlineWifi = (ns == ReachableViaWiFi);
        isOnlineCellular = (ns == ReachableViaWWAN);
    }
    DDLogInfo(@"reachability isOnline:%d wifi:%d cellular:%d", isOnline, isOnlineWifi, isOnlineCellular);
}

#pragma mark - Ios helpers

- (BOOL) isIos8
{
    return iOs8;
}

- (BOOL) isIphone
{
    return iPhone;
}

- (BOOL) isIpad
{
    return iPad;
}

- (void) setupDatabase
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"version1.sqlite"];
    
    //test cascade delete
    //[user deleteEntity];
    //[[NSManagedObjectContext defaultContext] save];
    
    //add account types if absent
    NSDictionary * conf = [NSDictionary dictionaryWithObjectsAndKeys: 
                           @"МТС", [NSNumber numberWithInt:kAccountMts],
                           @"Velcom", [NSNumber numberWithInt:kAccountVelcom],
                           @"Life :)", [NSNumber numberWithInt:kAccountLife],
                           @"Деловая сеть", [NSNumber numberWithInt:kAccountBn],
                           @"TCM", [NSNumber numberWithInt:kAccountTcm],
                           @"НИКС", [NSNumber numberWithInt:kAccountNiks],
                           @"Шпаркі Дамавік", [NSNumber numberWithInt:kAccountDamavik],
                           @"Соло", [NSNumber numberWithInt:kAccountSolo],
                           @"Телесеть", [NSNumber numberWithInt:kAccountTeleset],
                           @"Атлант Телеком", [NSNumber numberWithInt:kAccountAtlantTelecom],
                           @"ByFly", [NSNumber numberWithInt:kAccountByFly],
                           @"NetBerry", [NSNumber numberWithInt:kAccountNetBerry],
                           @"Космос ТВ", [NSNumber numberWithInt:kAccountCosmosTv],
                           @"Домашняя сеть", [NSNumber numberWithInt:kAccountInfolan],
                           @"UNET.BY", [NSNumber numberWithInt:kAccountUnetBy],
                           @"БелCел", [NSNumber numberWithInt:kAccountDiallog],
                           @"Anitex", [NSNumber numberWithInt:kAccountAnitex],
                           @"ADSL.BY", [NSNumber numberWithInt:kAccountAdslBy],
                           nil];
    
    BBMAccountType * item = nil;
    NSString * name = nil;
    BOOL added = NO;
    for (NSNumber * key in conf)
    {
        name = [conf objectForKey:key];
        //DDLogInfo(@"%@ = %@", key, name);
        item = [BBMAccountType findFirstByAttribute:@"id" withValue:key];
        
        if (item) continue;
        
        item = [BBMAccountType createEntity];
        item.id = key;
        item.name =  name;
        
        added = YES;
    }
    if (added) [self saveDatabase];
    
    NSInteger build = [SETTINGS.build integerValue];
    DDLogInfo(@"build in settings: %ld", (long)build);
    
    BOOL updated = NO;
    BBMAccount * acc;
    
    //added labels v1.4
    if (build < 41)
    {
        DDLogInfo(@"adding field: label");
        for (acc in [BBMAccount findAll])
        {
            if (!acc.label)
            {
                acc.label = @"";
                updated = YES;
            }
        }
        if (updated) [self saveDatabase];
        
        SETTINGS.build = [NSNumber numberWithInt:41];
        [SETTINGS save];
    }
    
    
    //added order v1.5
    if (build < 49)
    {
        DDLogInfo(@"adding field: order");
        updated = NO;
        for (acc in [BBMAccount findAll])
        {
            if ([acc.order integerValue] < 1)
            {
                acc.order = [BBMAccount nextOrder];
                updated = YES;
            }
        }
        if (updated) [self saveDatabase];
        
        SETTINGS.build = [NSNumber numberWithInt:49];
        [SETTINGS save];
    }
    
    //added velcom bonuses v1.6.6
    if (build < 68)
    {
        DDLogInfo(@"adding field: bonuses");
        for (acc in [BBMAccount findAll])
        {
            for (BBMBalanceHistory * history in acc.history)
            {
                if (!history.bonuses)
                {
                    history.bonuses = @"";
                    updated = YES;
                }
            }
        }
        if (updated) [self saveDatabase];
        
        SETTINGS.build = [NSNumber numberWithInt:68];
        [SETTINGS save];
    }
}

- (void) saveDatabase
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void) showAllAccounts
{
    BBMAccount * acc;
    NSArray * all = [BBMAccount findAll];
    for (acc in all)
    {
        DDLogVerbose(@"%@ %@ %@", acc.type.name, acc.username, acc.password);
    }
}

- (void) clearAllHistory
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    BBMAccount * acc;
    BBMBalanceHistory * bh;
    
    for (acc in [BBMAccount findAll])
    {
        for (bh in [acc history])
        {
            [bh deleteEntity];
        }
    }
    
    [APP_CONTEXT saveDatabase];
}

//
#pragma mark - Button helpers:
//
- (UIBarButtonItem *) backButton
{
    return [self buttonFromName:@"btn-back.png"];
}

- (UIBarButtonItem *) buttonFromName:(NSString *) resourceName
{
	NSAssert2(resourceName, @"%@ - Wrong resource name = %@", [self class], resourceName);
    
	UIImage * img = [self imageColored:resourceName];
	UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	[btn setImage:img forState:UIControlStateNormal];
	
	return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UILabel *) navBarLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:24.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [self colorRed];//[UIColor colorWithRed:229.f/255.f green:20.f/255.f blue:13.f/255.f alpha:1.f];
    return label;
}

- (UILabel *) toolBarLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [self colorRed];
    return label;
}

#pragma mark - Styles

- (UIColor *) colorRed
{
    return [UIColor colorWithRed:179.f/255.f green:0.f/255.f blue:0.f/255.f alpha:1.f];
}

- (UIColor *) colorGrayLight
{
    return [UIColor colorWithRed:170.f/255.f green:170.f/255.f blue:170.f/255.f alpha:1.f];
}

- (UIColor *) colorGrayMedium
{
    return [UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1.f];
}

- (UIColor *) colorGrayDark
{
    return [UIColor colorWithRed:85.f/255.f green:85.f/255.f blue:85.f/255.f alpha:1.f];
}

- (UIColor *) colorBg
{
    return [UIColor colorWithRed:37.f/255.f green:37.f/255.f blue:37.f/255.f alpha:1.f];
}

- (UIImage *) imageColored:(NSString *)resourceName
{
    return [[UIImage imageNamed:resourceName] changeColor:[self colorRed]];
}

- (void) makeRedButton:(UIButton *) button
{
    [[button layer] setCornerRadius:12.0f];
    //[[button layer] setBorderWidth:1.0f];
    //[[button layer] setBorderColor:[[UIColor blackColor] CGColor]];
    //button.alpha = 0.8f;
    [button setBackgroundColor:[self colorRed]];
    [button setTitleColor:[UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1] forState:UIControlStateNormal];
}

- (CGFloat) labelTextWidth:(UILabel *)label
{
    CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                                        options:(NSStringDrawingTruncatesLastVisibleLine)
                                                     attributes:@{NSFontAttributeName:label.font}
                                                        context:nil];
        
    return expectedLabelSize.size.width;
}

- (UIView *)circleWithColor:(UIColor *)color radius:(int)radius
{
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * radius, 2 * radius)];
    circle.backgroundColor = color;
    circle.layer.cornerRadius = radius;
    circle.layer.masksToBounds = YES;
    return circle;
}

- (void) makeRedCircle:(UIView *)circle
{
    circle.backgroundColor = [self colorRed];
    circle.layer.cornerRadius = circle.frame.size.width/2;
    circle.layer.masksToBounds = YES;
}

//
#pragma mark - UIAlertView variations:
//
- (void) showAlertForNoInternet
{
	//[self showAlertWithTitle: kAppNoInternetAlertTitle andText: kAppNoInternetAlertText];
    [self showToastWithText:kAppNoInternetAlertText];
}

- (void) showAlertWithTitle:(NSString *) anTitle andText:(NSString *) anText
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle: anTitle
													 message: anText
													delegate: nil
										   cancelButtonTitle: @"Close"
										   otherButtonTitles: nil];
	[alert show];
}

- (void) showAlertWithTitle:(NSString *) anTitle andText:(NSString *) anText andDelegate:(id<UIAlertViewDelegate>) anDelegate andButtonsTitles:(NSArray *) arrButtonsTitles
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle: anTitle
													 message: anText
													delegate: anDelegate
										   cancelButtonTitle: [arrButtonsTitles objectAtIndex:0]
										   otherButtonTitles: nil];
	int counter = 0;
	for( NSString * s in arrButtonsTitles)
	{		
		if( 0 == counter++ )
			continue;
		
		[alert addButtonWithTitle: s];
	}
    
	[alert show];
}

- (void) showAlertFromError:(NSError *) error
{
    if (!error) return;
    
    //TODO
    //make user friendly texts
    
    [self showAlertWithTitle:@"" andText:@"Unknown error"];
}

//
- (void) showToastWithText:(NSString *)aText
{
    [[iToast makeText:aText] show];
}

//
- (NSString *) basePath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

//
- (NSString *) numEnding:(NSInteger)num inArr:(NSArray *)arr
{
    //(1, 4, 5)
    int number = abs(num);
    int mod1 = number % 100;
    if (mod1 >= 11 && mod1 <= 19)
    {
        return [arr objectAtIndex:2];
    }
    else
    {
        int mod2 = mod1 % 10;
        switch (mod2)
        {
            case 1: return [arr objectAtIndex:0];
                
            case 2:
            case 3:
            case 4: return [arr objectAtIndex:1];
                
            default: return [arr objectAtIndex:2];
        }
    }
}
- (NSString *) formatWordAccount:(NSInteger)num
{
    //1,4,5
    return [self numEnding:num inArr:[NSArray arrayWithObjects:@"аккаунт", @"аккаунта", @"аккаунтов", nil]];
}

- (NSString *) formatWordCrossed:(NSInteger)num
{
    //1,4,5
    return [self numEnding:num inArr:[NSArray arrayWithObjects:@"пересёк", @"пересекли", @"пересекли", nil]];
}

@end
