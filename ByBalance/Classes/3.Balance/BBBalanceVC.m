//
//  BBBalanceVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceVC.h"
#import "BBAccountFormVC.h"
#import "BBBalanceHistoryCell.h"


typedef enum
{
	kAlertModeDeleteAccount,
	kAlertModeClearHistory,
	
} kAlertMode;



@interface BBBalanceVC ()

@property (strong, nonatomic) NSArray * history;

- (void) onBtnEdit:(id)sender;
- (void) onBtnDelete:(id)sender;
- (void) updateScreen;
- (void) clearHistory;

@end

@implementation BBBalanceVC

@synthesize account;
@synthesize history;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tblHistory setSeparatorColor:[UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1]];
    
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
    [vc release];
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
    
    NSString * msg = [NSString stringWithFormat:@"Будут оставлены последние %d записей. Очистить историю?", historyStay];
    
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
    NSLog(@"BBBalanceVC.balanceChecked");
    
    BBMAccount * updatedAcc = [[notification userInfo] objectForKey:kDictKeyAccount];
    if (!updatedAcc) return;
    
    if ([updatedAcc.type.id integerValue] == [self.account.type.id integerValue] &&
        updatedAcc.username == self.account.username)
    {
        NSLog(@"account matches");
        [self updateScreen];
    }
}

#pragma mark - Private

- (void) updateScreen
{
    lblType.text = account.type.name;
    lblName.text = account.username;
    
    BBMBalanceHistory * bh = account.lastGoodBalance;
    if (bh)
    {
        lblDate.text = [NSDateFormatter localizedStringFromDate:bh.date 
                                                      dateStyle:NSDateFormatterMediumStyle
                                                      timeStyle:NSDateFormatterNoStyle];
        
        lblBalance.text = [NSNumberFormatter localizedStringFromNumber:bh.balance
                                                           numberStyle:kCFNumberFormatterDecimalStyle];
    }
    else 
    {
        lblDate.text = @"";
        lblBalance.text = @"не обновлялся";
    }
    
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"account=%@", self.account];
    self.history = [BBMBalanceHistory findAllSortedBy:@"date"
                                            ascending:NO
                                        withPredicate:predicate];
        
    [tblHistory reloadData];
    
    btnClear.hidden = ([history count] <= historyStay);
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
            
            NSString * msg = [NSString stringWithFormat:@"История очищена. Оставлены последние %d записей.", historyStay];
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
    static NSString * cellId = @"BBBalanceHistoryCellID";
    NSArray * nibs;
    
    BBBalanceHistoryCell * cell = (BBBalanceHistoryCell*)[tblHistory dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        nibs = [[NSBundle mainBundle] loadNibNamed:@"BBBalanceHistoryCell" owner:self options:nil];
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
    return kBalanceHistoryCellHeight;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

@end
