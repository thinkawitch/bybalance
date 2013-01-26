//
//  BBAddAccountVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBAccountFormVC.h"
#import "SSCheckBoxView.h"

@interface BBAccountFormVC ()

- (void) updateScreenForType;
- (NSString *) loginTitle;

@end

@implementation BBAccountFormVC

@synthesize accountType;
@synthesize editMode;
@synthesize account;
@synthesize cellPhone;

- (void)viewDidLoad
{
    if (editMode) self.accountType = self.account.type;
    
    [super viewDidLoad];
    
    [self updateScreenForType];
    
    [APP_CONTEXT makeRedButton:btnAdd];
    
    SSCheckBoxView *cbv = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(178, 96, 110, 30)
                                                          style:kSSCheckBoxViewStyleMono
                                                        checked:NO];
    [cbv setText:@"показать"];
    [cbv setStateChangedTarget:self selector:@selector(togglePasswordDisplay:)];
    [self.view addSubview:cbv];
    [cbv release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) cleanup
{
    
    [self.view endEditing:YES];
    
    self.accountType = nil;
    self.account = nil;
    
    [super cleanup];
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
    titleView.text = self.accountType.name;
    [titleView sizeToFit];
    
}

#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) hideKeyboard:(id) sender
{
    [self.view endEditing:YES];
}

- (IBAction) add:(id) sender
{
    if ([tfUsername.text length] < 1)
    {
        [APP_CONTEXT showToastWithText:[NSString stringWithFormat:@"Введите %@", [self loginTitle]]];
        return;
    }
    
    NSInteger type = [accountType.id integerValue];
    BOOL isPhone = (type == kAccountMts || type == kAccountVelcom || type ==kAccountLife);
    if (isPhone && [tfUsername.text length] != 9)
    {
        [APP_CONTEXT showToastWithText:@"Введите 9 цифр в номер телефона"];
        return;
    }
    
    if ([tfPassword.text length] < 1)
    {
        [APP_CONTEXT showToastWithText:@"Введите пароль"];
        return;
    }
    
    if (editMode)
    {
        account.username = tfUsername.text;
        account.password = tfPassword.text;
        [APP_CONTEXT saveDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnAccountsListUpdated object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [APP_CONTEXT showToastWithText:@"Аккаунт обновлён"];
    }
    else
    {
        BBMAccount * newAccount = [BBMAccount createEntity];
        newAccount.type = accountType;
        newAccount.username = tfUsername.text;
        newAccount.password = tfPassword.text;
        [APP_CONTEXT saveDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnAccountsListUpdated object:nil];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        [APP_CONTEXT showToastWithText:@"Новый аккаунт добавлен"]; 
    }
}

- (IBAction) togglePasswordDisplay:(id) sender
{
    [tfPassword resignFirstResponder];
    tfPassword.secureTextEntry = ![sender checked];
}


#pragma mark - Private

- (void) updateScreenForType
{
    NSInteger type = [accountType.id integerValue];
    cellPhone = NO;
    if (type == kAccountMts || type == kAccountVelcom || type == kAccountLife)
    {
        cellPhone = YES;
    }
    
    lblUsername.text = [self loginTitle];

    if (cellPhone)
    {
        lblUsernamePrefix.hidden = NO;
        tfUsername.frame = CGRectMake(85, 54, 201, 31);
        tfUsername.keyboardType = UIKeyboardTypeNumberPad;
        
    }
    else
    {
        lblUsernamePrefix.hidden = YES;
        tfUsername.frame = CGRectMake(35, 54, 251, 31);
        if (type == kAccountBn) tfUsername.keyboardType = UIKeyboardTypeNumberPad;
        else tfUsername.keyboardType = UIKeyboardTypeDefault;
    }
    
    if (editMode)
    {
        tfUsername.text = account.username;
        tfPassword.text = account.password;
        
        [btnAdd setTitle:@"Сохранить" forState:UIControlStateNormal];

    }
}

- (NSString *) loginTitle
{
    NSInteger type = [accountType.id integerValue];
    
    if (cellPhone)
    {
        return @"Номер телефона";
    }
    else
    {
        if (type == kAccountBn) return @"Номер счёта";
        if (type == kAccountTcm || type == kAccountNiks) return @"Логин";
    }
    
    return @"";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


@end
