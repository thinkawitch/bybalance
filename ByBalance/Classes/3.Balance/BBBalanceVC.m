//
//  BBBalanceVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBalanceVC.h"
#import "BBAccountFormVC.h"

@interface BBBalanceVC ()

- (void) onBtnEdit:(id)sender;
- (void) onBtnDelete:(id)sender;

@end

@implementation BBBalanceVC

@synthesize account;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lblType.text = account.type.name;
    lblName.text = account.username;
    
    [APP_CONTEXT makeRedButton:btnRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountsListUpdated:) name:kNotificationOnAccountsListUpdated object:nil];
}


- (void) cleanup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOnAccountsListUpdated object:nil];
    
    self.account = nil;
    
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
        lblType.text = account.type.name;
        lblName.text = account.username;
        
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
    [APP_CONTEXT showAlertWithTitle:@"" 
                            andText:@"Удалить этот аккаунт?" 
                        andDelegate:self 
                   andButtonsTitles:[NSArray arrayWithObjects:@"Нет", @"Да", nil]];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
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


@end
