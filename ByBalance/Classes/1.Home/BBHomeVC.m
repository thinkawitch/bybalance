//
//  BBHomeVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBHomeVC.h"
#import "BBSelectAccountTypeVC.h"
#import "BBHomeCell.h"
#import "BBBalanceVC.h"
#import "BBAboutVC.h"

@interface BBHomeVC ()

@property (strong,nonatomic) NSArray * accounts;

- (void) toggleSplashMode;

@end


@implementation BBHomeVC

@synthesize accounts;

#pragma mark - ObjectLife

- (void)viewDidLoad
{
    [super viewDidLoad];

    [tblAccounts setSeparatorColor:[UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1]];
    
    [APP_CONTEXT makeRedButton:btnBigAdd];
    
    self.accounts = [BBMAccount findAll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountsListUpdated:) name:kNotificationOnAccountsListUpdated object:nil];
    
    [self toggleSplashMode];
    
}

- (void) cleanup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnAccountsListUpdated object:nil];
    
    self.accounts = nil;
    
    [super cleanup];
}

- (void) accountsListUpdated:(NSNotification *)notification
{
    needUpdateScreen = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (needUpdateScreen)
    {
        self.accounts = [BBMAccount findAll];
        needUpdateScreen = NO;
        [self toggleSplashMode];
    }
}

- (void) toggleSplashMode
{
    if ([accounts count] > 0)
    {
        splashView.hidden = YES;
        tblAccounts.hidden = NO;
        [tblAccounts reloadData];
    }
    else 
    {
        tblAccounts.hidden = YES;
        splashView.hidden = NO;
    }
}

#pragma mark - Setup

- (void) setupNavBar
{
    [super setupNavBar];
    
    /*
    UIBarButtonItem * spacer = [[UIBarButtonItem alloc] 
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                target:nil action:nil];
    spacer.width = 10; 
    */
    
    //left button
    UIBarButtonItem * btnInfo = [APP_CONTEXT buttonFromName:@"info"]; //[APP_CONTEXT infoIconButton];
    [(UIButton *)btnInfo.customView addTarget:self action:@selector(onNavButtonLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = btnInfo;
    
    //title
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView.text = @"ByBalance";
    [titleView sizeToFit];
    
    //right button
    UIBarButtonItem * btnAdd = [APP_CONTEXT buttonFromName:@"add"];
    [(UIButton *)btnAdd.customView addTarget:self action:@selector(onNavButtonRight:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = btnAdd;
}

#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
    /*
    BBAboutVC * vc = NEWVCFROMNIB(BBAboutVC);
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalViewController:vc animated:YES];
    //[self.navigationController pushViewController:vc animated:YES];
    [vc release];
    */
    
    BBAboutVC * vc = NEWVCFROMNIB(BBAboutVC);
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc release];
    
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [self presentModalViewController:navController animated:YES];
    [navController release];
    
}

- (IBAction) onNavButtonRight:(id)sender
{
    BBSelectAccountTypeVC * vc = NEWVCFROMNIB(BBSelectAccountTypeVC);
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - Logic

- (IBAction) update:(id)sender
{
    if (![APP_CONTEXT isOnline])
    {
        [APP_CONTEXT showAlertForNoInternet];
        return;
    }
    
    /*
    NSError * error = nil;
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"mts_balance" ofType:@"html"];
    
    NSString * str = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:&error];
    //NSLog(@"%@", str);
    */
    
    BBItemMts *item = [[BBItemMts new] autorelease];
    item.username = @"xxxxxxxxx";
    item.password = @"xxx";
    
    BBLoaderBase * loader = [BBLoaderBase new];
    loader.item = item;
    loader.delegate = self;
    [loader start];
    
    [self showWaitIndicator:YES]; 
}

#pragma mark - BBLoaderDelegate

- (void) dataLoaderSuccess:(BBLoaderBase*)loader
{
    [self showWaitIndicator:NO];
    
    /*
    IDDateHelper * dh = [IDDateHelper sharedIDDateHelper];
    NSString * time = [dh dateToMysqlDateTime:[NSDate date]];
    textView.text = [textView.text stringByAppendingFormat:@"\r\n%@\r\n%@\r\n", time, loader.item.fullDescription];
    [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];

    [loader autorelease];
    
    SETTINGS.log = textView.text;
    */

}

- (void) dataLoaderFail:(BBLoaderBase*)loader
{
    [self showWaitIndicator:NO];
    
    /*
    IDDateHelper * dh = [IDDateHelper sharedIDDateHelper];
    NSString * time = [dh dateToMysqlDateTime:[NSDate date]];
    textView.text = [textView.text stringByAppendingFormat:@"\r\n%@\r\n%@\r\n", time, loader.item.fullDescription];
    [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
    
    [loader autorelease];
    
    SETTINGS.log = textView.text;
    */
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"BBHomeCellID";
    NSArray * nibs;
    
    BBHomeCell * cell = (BBHomeCell*)[tblAccounts dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        nibs = [[NSBundle mainBundle] loadNibNamed:@"BBHomeCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    BBMAccount * account = [self.accounts objectAtIndex:indexPath.row];
    
    [cell setupWithAccount:account];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHomeCellHeight;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBHomeCell * cell = (BBHomeCell *)[tblAccounts cellForRowAtIndexPath:indexPath];
    if (nil == cell)
    {
        NSAssert(0, @"%@. Cell is nil", [self class]);
        return;
    }
    
    BBBalanceVC * vc = NEWVCFROMNIB(BBBalanceVC);
    vc.account = cell.account;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}



@end
