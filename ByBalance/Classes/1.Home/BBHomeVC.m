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

- (void) loadAccounts;
- (void) setupToolbar;
- (void) toggleSplashMode;
- (NSString *) lastBalanceStatus;

- (void) onBtnReorder:(id)sender;
- (void) switchToReorder;
- (void) switchFromReorder;

@end


@implementation BBHomeVC

@synthesize accounts;

#pragma mark - ObjectLife

- (void)viewDidLoad
{
    [super viewDidLoad];

    [tblAccounts setSeparatorColor:[UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1]];
    
    [APP_CONTEXT makeRedButton:btnBigAdd];
    
    [self setupToolbar];
    [self loadAccounts];
    [self toggleSplashMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountsListUpdated:) name:kNotificationOnAccountsListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceCheckStarted:) name:kNotificationOnBalanceCheckStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceCheckProgress:) name:kNotificationOnBalanceCheckProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceCheckStopped:) name:kNotificationOnBalanceCheckStop object:nil];
}

- (void) cleanup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnAccountsListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnBalanceCheckStart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnBalanceCheckProgress object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnBalanceCheckStop object:nil];
    
    self.accounts = nil;
    
    if (btnRefresh)
    {
        [btnRefresh release];
        btnRefresh = nil;
    }
    
    if (lblStatus)
    {
        [lblStatus release];
        lblStatus = nil;
    }
    
    if (vActivity)
    {
        [vActivity release];
        vActivity = nil;
    }
    
    if (btnReorder)
    {
        [btnReorder release];
        btnReorder = nil;
    }
    
    [super cleanup];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (needUpdateScreen)
    {
        [self loadAccounts];
        needUpdateScreen = NO;
        [self toggleSplashMode];
    }
    
    [[[GAI sharedInstance] defaultTracker] sendView:@"Главный экран"];
    
}


#pragma mark - Setup

- (void) setupNavBar
{
    [super setupNavBar];
    
    
    UIBarButtonItem * spacer = [[UIBarButtonItem alloc] 
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                target:nil action:nil];
    spacer.width = 5; 
    
    
    //left button
    UIBarButtonItem * btnInfo = [APP_CONTEXT buttonFromName:@"info"]; //[APP_CONTEXT infoIconButton];
    [(UIButton *)btnInfo.customView addTarget:self action:@selector(onNavButtonLeft:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.leftBarButtonItem = btnInfo;
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:spacer, btnInfo, nil]];
    
    //title
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView.text = @"БайБаланс";
    [titleView sizeToFit];
    
    //right button
    UIBarButtonItem * btnAdd = [APP_CONTEXT buttonFromName:@"add"];
    [(UIButton *)btnAdd.customView addTarget:self action:@selector(onNavButtonRight:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.rightBarButtonItem = btnAdd;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:spacer, btnAdd, nil]];
}

- (void) setupToolbar
{
    //refresh
    UIImage * img = [UIImage imageNamed:@"refresh"];
	btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	[btnRefresh setImage:img forState:UIControlStateNormal];
    [btnRefresh addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
	
    //activity
    vActivity =  [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] retain];
    vActivity.color = [UIColor colorWithRed:229.f/255.f green:20.f/255.f blue:13.f/255.f alpha:1.f];
    vActivity.hidesWhenStopped = YES;
    
    //status
    lblStatus = [[APP_CONTEXT toolBarLabel] retain];
    lblStatus.text = [self lastBalanceStatus];
    [lblStatus sizeToFit];
    
    //reorder
    UIImage * img2 = [UIImage imageNamed:@"reorder"];
	btnReorder = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img2.size.width, img2.size.height)];
	[btnReorder setImage:img2 forState:UIControlStateNormal];
    [btnReorder addTarget:self action:@selector(onBtnReorder:) forControlEvents:UIControlEventTouchUpInside];
	
    //toolbar
    UIBarButtonItem * bbiRefresh = [[[UIBarButtonItem alloc] initWithCustomView:btnRefresh] autorelease];
    UIBarButtonItem * bbiSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
    UIBarButtonItem * bbiActivity = [[UIBarButtonItem alloc] initWithCustomView:vActivity];
    UIBarButtonItem * bbiLabel = [[UIBarButtonItem alloc] initWithCustomView:lblStatus];
    UIBarButtonItem * bbiSpacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
    UIBarButtonItem * bbiReorder = [[[UIBarButtonItem alloc] initWithCustomView:btnReorder] autorelease];
    
    NSArray *items = [[NSArray alloc] initWithObjects:bbiRefresh, bbiSpacer, bbiActivity, bbiLabel, bbiSpacer2, bbiReorder, nil];
    [toolbar setItems:items];
}

#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
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
    if (tblAccounts.editing) [self switchFromReorder];
    
    BBSelectAccountTypeVC * vc = NEWVCFROMNIB(BBSelectAccountTypeVC);
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - Logic

- (void) loadAccounts
{
    self.accounts = [NSMutableArray arrayWithArray:[BBMAccount findAllSortedBy:@"order" ascending:YES]];
    
    btnReorder.hidden = [accounts count] < 2;
    [lblStatus sizeToFit];
}

- (IBAction) update:(id)sender
{
    if (![APP_CONTEXT isOnline])
    {
        [APP_CONTEXT showAlertForNoInternet];
        return;
    }
    
    //nothing to update
    if ([self.accounts count] < 1)
    {
        return;
    }
    
    if ([BALANCE_CHECKER isBusy])
    {
        [APP_CONTEXT showToastWithText:@"Идёт обновление, подождите"];
        return;
    }
    
    if (tblAccounts.editing) [self switchFromReorder];
    
    for (BBMAccount * account in accounts)
    {
        [BALANCE_CHECKER addItem:account];
    }
}

- (void) onBtnReorder:(id)sender
{
    if ([BALANCE_CHECKER isBusy])
    {
        [APP_CONTEXT showToastWithText:@"Идёт обновление, подождите"];
        return;
    }
    
    if (tblAccounts.editing) [self switchFromReorder];
    else [self switchToReorder];
}

- (void) switchToReorder
{
    [tblAccounts setEditing:YES animated:YES];
}

- (void) switchFromReorder
{
    [tblAccounts setEditing:NO animated:YES];
}

#pragma mark - Notifications

- (void) accountsListUpdated:(NSNotification *)notification
{
    needUpdateScreen = YES;
}

- (void) balanceCheckStarted:(NSNotification *)notification
{
    NSLog(@"BBHomeVC.balanceCheckStarted");
    
    [vActivity startAnimating];
    
    lblStatus.text = @"обновление началось";
    [lblStatus sizeToFit];
}

- (void) balanceCheckProgress:(NSNotification *)notification
{
    NSLog(@"BBHomeVC.balanceCheckProgress");
    
    BBMAccount * account = [[notification userInfo] objectForKey:kDictKeyAccount];
    if (account)
    {
        NSLog(@"обновляю %@ %@", account.username, account.nameLabel);
        lblStatus.text = [NSString stringWithFormat:@"обновляю %@", account.nameLabel];
        [lblStatus sizeToFit];
    }
    
    [tblAccounts reloadData];
}

- (void) balanceCheckStopped:(NSNotification *)notification
{
    NSLog(@"BBHomeVC.balanceCheckStopped");
    
    [vActivity stopAnimating];
    
    lblStatus.text = [self lastBalanceStatus];
    [lblStatus sizeToFit];
    
    [tblAccounts reloadData];
}

#pragma mark - Private

- (void) toggleSplashMode
{
    if ([self.accounts count] > 0)
    {
        splashView.hidden = YES;
        tblAccounts.hidden = NO;
        [tblAccounts reloadData];
        toolbar.hidden = NO;
    }
    else 
    {
        tblAccounts.hidden = YES;
        splashView.hidden = NO;
        toolbar.hidden = YES;
    }
}

- (NSString *) lastBalanceStatus;
{
    NSArray * arr = [BBMBalanceHistory findAllSortedBy:@"date" ascending:NO];
    
    if (!arr || [arr count] < 1) return @"ещё не обновлялся";
    
    BBMBalanceHistory * bh = [arr objectAtIndex:0];
    
    NSString * strDate = [NSDateFormatter localizedStringFromDate:bh.date 
                                                        dateStyle:NSDateFormatterMediumStyle
                                                        timeStyle:NSDateFormatterShortStyle];
    
    return [NSString stringWithFormat:@"обновлено %@", strDate];
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
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    BBMAccount * account = [self.accounts objectAtIndex:indexPath.row];
    
    [cell setupWithAccount:account];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSObject *tempObj = [[self.accounts objectAtIndex:sourceIndexPath.row] retain];
    [self.accounts removeObjectAtIndex:sourceIndexPath.row];
    [self.accounts insertObject:tempObj atIndex:destinationIndexPath.row];
    [tempObj release];
    
    //save new order
    BBMAccount * acc;
    NSInteger order = 1;
    for (acc in self.accounts)
    {
        acc.order = [NSNumber numberWithInteger:order];
        order++;
    }
    [APP_CONTEXT saveDatabase];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHomeCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}



@end
