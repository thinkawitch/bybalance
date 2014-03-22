//
//  BBBalanceVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceVC.h"
#import "BBAccountFormVC.h"
#import "BBHistoryAllCells.h"


typedef enum
{
	kAlertModeDeleteAccount,
	kAlertModeClearHistory,
	
} kAlertMode;



@interface BBBalanceVC ()

@property (strong, nonatomic) NSArray * history;
@property (strong,nonatomic) UIView * vCircle;

- (void) onBtnEdit:(id)sender;
- (void) onBtnDelete:(id)sender;
- (void) updateScreen;
- (void) clearHistory;

@end

@implementation BBBalanceVC

@synthesize account;
@synthesize history;
@synthesize vCircle;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tblHistory setSeparatorColor:[APP_CONTEXT colorGrayMedium]];
    
    historyStay = 5;
    
    [self updateScreen];
    
    [APP_CONTEXT makeRedButton:btnRefresh];
    [APP_CONTEXT makeRedButton:btnClear];
    btnClear.alpha = 0.7f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountsListUpdated:) name:kNotificationOnAccountsListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceChecked:) name:kNotificationOnBalanceChecked object:nil];
}


- (void) cleanup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnAccountsListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnBalanceChecked object:nil];
    
    self.account = nil;
    self.history = nil;
    
    [super cleanup];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (needUpdateScreen)
    {
        [self updateScreen];
        
        needUpdateScreen = NO;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Баланс"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
}

#pragma mark - Setup

- (void) setupNavBar
{
    [super setupNavBar];
    
    //left button
    UIBarButtonItem * btnInfo = [APP_CONTEXT buttonFromName:@"arrow_left"];
    [(UIButton *)btnInfo.customView addTarget:self action:@selector(onNavButtonLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = btnInfo;
    
    //title
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView.text = @"Баланс";
    [titleView sizeToFit];
    
    //right button
    UIBarButtonItem * btnEdit = [APP_CONTEXT buttonFromName:@"edit"];
    [(UIButton *)btnEdit.customView addTarget:self action:@selector(onBtnEdit:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * btnDelete = [APP_CONTEXT buttonFromName:@"delete"];
    [(UIButton *)btnDelete.customView addTarget:self action:@selector(onBtnDelete:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnDelete, btnEdit, nil];
    
}


#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onBtnEdit:(id)sender
{
    BBAccountFormVC * vc = NEWVCFROMNIB(BBAccountFormVC);
    vc.account = self.account;
    vc.editMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onBtnDelete:(id)sender
{
    
    alertMode = kAlertModeDeleteAccount;
    
    [APP_CONTEXT showAlertWithTitle:@"" 
                            andText:@"Удалить этот аккаунт?" 
                        andDelegate:self 
                   andButtonsTitles:[NSArray arrayWithObjects:@"Нет", @"Да", nil]];
}

- (IBAction) onBtnRefresh:(id)sender
{
    if (![APP_CONTEXT isOnline])
    {
        [APP_CONTEXT showAlertForNoInternet];
        return;
    }
    
    if ([BALANCE_CHECKER isBusy])
    {
        [APP_CONTEXT showToastWithText:@"Идёт обновление, подождите"];
        return;
    }
    
    //add one account
    [BALANCE_CHECKER addItem:account];
}

- (IBAction) onBtnClear:(id)sender
{
    if (!history) return;
    
    NSInteger total = [history count];
    
    if (total <= historyStay) return;
    
    alertMode = kAlertModeClearHistory;
    
    NSString * msg = [NSString stringWithFormat:@"Будут оставлены последние %ld записей. Очистить историю?", (long)historyStay];
    
    [APP_CONTEXT showAlertWithTitle:@"" 
                            andText:msg 
                        andDelegate:self
                   andButtonsTitles:[NSArray arrayWithObjects:@"Нет", @"Да", nil]];
}


#pragma mark - Notifications

- (void) accountsListUpdated:(NSNotification *)notification
{
    needUpdateScreen = YES;
}

- (void) balanceChecked:(NSNotification *)notification
{
    DDLogVerbose(@"BBBalanceVC.balanceChecked");
    
    BBMAccount * updatedAcc = [[notification userInfo] objectForKey:kDictKeyAccount];
    if (!updatedAcc) return;
    
    if ([updatedAcc.type.id integerValue] == [self.account.type.id integerValue] &&
        updatedAcc.username == self.account.username)
    {
        DDLogVerbose(@"account matches");
        [self updateScreen];
    }
}

#pragma mark - Private

- (void) updateScreen
{
    lblType.text = account.type.name;
    lblName.text = account.username;
    lblLabel.text = account.label;
    
    lblDate.text = [account lastGoodBalanceDate];
    lblBalance.text = [account lastGoodBalanceValue];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"account=%@", self.account];
    self.history = [BBMBalanceHistory findAllSortedBy:@"date"
                                            ascending:NO
                                        withPredicate:predicate];
    
    if ([history count] < 1)
    {
        //no history
        tblHistory.hidden = YES;
        btnClear.hidden = YES;
        lblHistory.hidden = YES;
    }
    else
    {
        //update table
        tblHistory.hidden = NO;
        [tblHistory reloadData];
        lblHistory.hidden = NO;
        btnClear.hidden = ([history count] <= historyStay);
    }
    
    
    if ([account balanceLimitCrossed])
    {
        if (!self.vCircle)
        {
            self.vCircle = [APP_CONTEXT circleWithColor:[APP_CONTEXT colorRed] radius:5];
            [self.view addSubview:vCircle];
        }
        
        CGFloat textWidth = [APP_CONTEXT labelTextWidth:lblBalance];
        CGFloat circleX = lblBalance.frame.origin.x + lblBalance.frame.size.width - textWidth - vCircle.frame.size.width - 3;
        CGFloat circleY = lblBalance.frame.origin.y + (lblBalance.frame.size.height - vCircle.frame.size.height)/2;
        vCircle.frame = CGRectMake(circleX, circleY, vCircle.frame.size.width, vCircle.frame.size.height);
    }
    else
    {
        [self.vCircle removeFromSuperview];
        self.vCircle = nil;
    }
}

- (void) clearHistory
{
    NSInteger c = 0;
    NSInteger total = [history count];
    
    if (total <= historyStay) return;
    
    for (BBMBalanceHistory * bh in history)
    {
        c++;
        if (c > historyStay)
        {
            [bh deleteEntity];
        }
    }
    
    [APP_CONTEXT saveDatabase];
    
    [self updateScreen];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertMode == kAlertModeDeleteAccount)
    {    
        if (buttonIndex == 1)
        {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"account"
                                                                  action:@"account_delete"
                                                                   label:[NSString stringWithFormat:@"%@", account.type.name]
                                                                   value:nil] build]];
            
            [account deleteEntity];
            [APP_CONTEXT saveDatabase];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnAccountsListUpdated object:nil];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            [APP_CONTEXT showToastWithText:@"Аккаунт удалён"]; 
        }
    }
    
    if (alertMode == kAlertModeClearHistory)
    {    
        if (buttonIndex == 1)
        {
            [self clearHistory];
            
            NSString * msg = [NSString stringWithFormat:@"История очищена. Оставлены последние %ld записей.", (long)historyStay];
            [APP_CONTEXT showToastWithText:msg]; 
        }
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.history count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId1 = @"BBHistoryCommonCellID";
    static NSString * cellId2 = @"BBHistoryAnitexCellID";
    
    static NSString * nib1 = @"BBHistoryCommonCell";
    static NSString * nib2 = @"BBHistoryAnitexCell";
    
    NSString * cellId = [self.account.type.id integerValue] == kAccountAnitex ? cellId2 : cellId1;
    NSString * nib = [self.account.type.id integerValue] == kAccountAnitex ? nib2 : nib1;
    
    NSArray * nibs;
    
    BBHistoryBaseCell * cell = (BBHistoryBaseCell*)[tblHistory dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        nibs = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    
    BBMBalanceHistory * bh = [self.history objectAtIndex:indexPath.row];
    [cell setupWithHistory:bh];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.account.type.id integerValue] == kAccountAnitex ? kHistoryCellHeight2 : kHistoryCellHeight1;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

@end
