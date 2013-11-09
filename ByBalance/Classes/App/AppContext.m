//
//  AppContext.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "AppContext.h"
#import "Reachability.h"
#import "iToast.h"
#import <QuartzCore/QuartzCore.h>

@interface AppContext ()
- (void) setupDatabase;
- (void) reachabilityChanged:(NSNotification *)note;
@end

@implementation AppContext

SYNTHESIZE_SINGLETON_FOR_CLASS(AppContext, sharedAppContext);
@synthesize doBgFetch;

#pragma mark - Public

- (void) start
{
    //reachabilityWithHostName: api server 
	reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	[reachability startNotifier];
    
    //consider we have internet by default, because we need some time to check if connection is real
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
    //[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        doBgFetch = YES;
    }
}

- (void) stop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [self saveDatabase];
    [MagicalRecord cleanUp];
    
	[reachability stopNotifier];
	reachability = nil;
}

#pragma mark - Reachability

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
    DDLogInfo(@"reachabilityChanged: isOnline:%d isOnlineWifi:%d isOnlineCellular:%d", isOnline, isOnlineWifi, isOnlineCellular);
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
    DDLogInfo(@"build in settings: %d", build);
    
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

//
#pragma mark - Button helpers:
//
- (UIBarButtonItem *) backButton
{
    return [self buttonFromName:@"btn-back.png"];
}


- (UIBarButtonItem *) buttonFromName:(NSString *) resourceName
{
	NSAssert2( resourceName, @"%@ - Wrong resource name = %@", [self class], resourceName);
    
	UIImage * img = [UIImage imageNamed:resourceName];
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
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:229.f/255.f green:20.f/255.f blue:13.f/255.f alpha:1.f];
    return label;
}

- (UILabel *) toolBarLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:229.f/255.f green:20.f/255.f blue:13.f/255.f alpha:1.f];
    return label;
}

#pragma mark - Styles

- (void) makeRedButton:(UIButton *) button
{
    [[button layer] setCornerRadius:12.0f];
    //[[button layer] setBorderWidth:1.0f];
    //[[button layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [button setBackgroundColor:[UIColor colorWithRed:179.f/255.f green:20.f/255.f blue:13.f/255.f alpha:1.f]];
    [button setTitleColor:[UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1] forState:UIControlStateNormal];
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

@end
