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
#import "AFNetworking.h"

@interface AppContext ()

- (void) reachabilityChanged:(NSNotification *)note;

@end

@implementation AppContext

SYNTHESIZE_SINGLETON_FOR_CLASS(AppContext);

@synthesize isOnline;

//
#pragma mark - Public
//
- (void) startContext
{
    //reachabilityWithHostName: api server 
	reachability = [[Reachability reachabilityWithHostName:@"google.com"] retain];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	[reachability startNotifier];
    
    //consider we have internet by default, because we need some time to check if connection is real
    self.isOnline = YES;
    
    //
    [self setupDatabase];
    
    //
    iToastSettings * ts = [iToastSettings getSharedSettings];
    ts.duration = 3000;
    
    //
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

- (void) stopContext
{
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
	[reachability stopNotifier];
	[reachability release];
	reachability = nil;
}

- (void) setupDatabase
{
    //[ActiveRecordHelpers setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"version1.sqlite"];
    [MagicalRecordHelpers setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"version1.sqlite"];
    
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
                           @"ByFly", [NSNumber numberWithInt:kAccountByFly],
                           @"NetBerry", [NSNumber numberWithInt:kAccountNetBerry],
                           @"Космос ТВ", [NSNumber numberWithInt:kAccountCosmosTv],
                           nil];
    
    BBMAccountType * item = nil;
    NSString * name = nil;
    BOOL added = NO;
    for (NSNumber * key in conf)
    {
        name = [conf objectForKey:key];
        //NSLog(@"%@ = %@", key, name);
        item = [BBMAccountType findFirstByAttribute:@"id" withValue:key];
        
        if (item) continue;
        
        item = [BBMAccountType createEntity];
        item.id = key;
        item.name =  name;
        
        added = YES;
    }
    if (added) [self saveDatabase];
    
    
    BOOL updated = NO;
    BBMAccount * acc;
    for (acc in [BBMAccount findAll])
    {
        if (!acc.label)
        {
            acc.label = @"";
            updated = YES;
        }
    }
    if (updated) [self saveDatabase];
}

- (void) saveDatabase
{
    //[[NSManagedObjectContext defaultContext] save];
    [[NSManagedObjectContext MR_defaultContext] MR_save];
}

//
#pragma mark - Button helpers:
//
- (UIBarButtonItem *) backButton
{
    return [self buttonFromName:@"btn-back.png"];
}

- (UIBarButtonItem *) menuButton
{
	UIImage * img = [UIImage imageNamed:@"shared_btn_menu.png"];
	UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	[btn setImage:img forState:UIControlStateNormal];
	
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[btn release];
	
	return [btnBackItem autorelease];
}

- (UIBarButtonItem *) addIconButton;
{
	UIButton * btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[btn release];

	return [btnBackItem autorelease];
}

- (UIBarButtonItem *) infoIconButton;
{
	UIButton * btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[btn release];
    
	return [btnBackItem autorelease];
}

- (UIBarButtonItem *) buttonFromName:(NSString *) resourceName
{
	NSAssert2( resourceName, @"%@ - Wrong resource name = %@", [self class], resourceName);
    
	UIImage * img = [UIImage imageNamed:resourceName];
	UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	[btn setImage:img forState:UIControlStateNormal];
	
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[btn release];
	
	return [btnBackItem autorelease];
}

- (UIBarButtonItem *) buttonWithTitle:(NSString *) anTitle
{
    //	NSAssert2( resourceName, @"%@ - Wrong resource name = %@", [self class], resourceName);
	
	UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(0, 0, 100, 44);
	btn.autoresizingMask			= UIViewAutoresizingFlexibleWidth;
    //	btn.contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
    //    btn.contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
    //	btn.adjustsImageWhenDisabled	= YES;
    //    btn.adjustsImageWhenHighlighted	= YES;
	
	UIImage * img = [self stretchedImageNamed:@"shared_btn_blue.png" width:CGRectMake(0, 0, 7, 0)];
	
	[btn setTitle:anTitle forState:UIControlStateNormal];
	[btn setBackgroundImage:img forState:UIControlStateNormal];
    
	CGRect rcTitle = [btn titleRectForContentRect:CGRectMake(0, 0, 100, 44)];
	NSLog(@"rcTitle = %@, size = %@", NSStringFromCGRect(rcTitle), NSStringFromCGSize(img.size));
	btn.frame = CGRectMake(0, 0, 100, img.size.height);
	rcTitle = [btn titleRectForContentRect:CGRectMake(0, 0, 100, 44)];
	NSLog(@"rcTitle = %@, size = %@", NSStringFromCGRect(rcTitle), NSStringFromCGSize(img.size));
	
	
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	return [btnBackItem autorelease];
}

- (UIImage *) stretchedImageNamed:(NSString *) anName width:(CGRect)anRect
{
	UIImage * imgResult = nil;
	UIImage * imgSource = [UIImage imageNamed:anName];
	
	if( imgSource )
	{
#ifdef __IPHONE_5_0
		if( [imgSource respondsToSelector:@selector(resizableImageWithCapInsets:)] )
		{
			imgResult = [imgSource resizableImageWithCapInsets:UIEdgeInsetsMake(0, anRect.size.width, 0, anRect.size.width)];
		}
		else // Support iOS version prior to the 5.0
#endif
		{
			imgResult = [imgSource stretchableImageWithLeftCapWidth:anRect.size.width topCapHeight:0];
		}
	}
	
	return imgResult;
}

- (UILabel *) navBarLabel
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:24.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:229.f/255.f green:20.f/255.f blue:13.f/255.f alpha:1.f];
    return label;
}

- (UILabel *) toolBarLabel
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
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
#pragma mark - Reachability
//
- (void) reachabilityChanged:(NSNotification *)note
{
    NSLog(@"reachabilityChanged:%@", note);
	self.isOnline = !([reachability currentReachabilityStatus] == NotReachable);
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
	[alert release];
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
	[alert release];
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
- (BOOL) stringIsNumeric:(NSString *) str
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    [formatter release];
    return !!number; // If the string is not numeric, number will be nil
}


@end
