//
//  BBAddAccountVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBAccountFormVC.h"
#import "SSCheckBoxView.h"
#import "BBSelectCheckPeriodVC.h"

@interface BBAccountFormVC ()
{
    BOOL isFormUp;
}
- (void) updateScreenForType;
- (NSString *) loginTitle;
- (NSString *) passwordTitle;
- (void) displayPersonPhone:(ABRecordRef)person;
- (void) keyboardDidShow:(NSNotification *)notification;
- (void) keyboardDidHide:(NSNotification *)notification;
- (void) moveFormUp;
- (void) placeFormNormal;
- (void) updateCheckPeriodTitle;
- (void) openSelectCheckPeriod;

@end

@implementation BBAccountFormVC

@synthesize accountType;
@synthesize editMode;
@synthesize account;
@synthesize cellPhone;
@synthesize currPeriodicCheck;

- (void) viewDidLoad
{
    if (editMode)
    {
        self.accountType = self.account.type;
        currPeriodicCheck = [self.account.periodicCheck intValue];
    }
    else
    {
        currPeriodicCheck = kPeriodicCheckManual;
    }
    
    [super viewDidLoad];
    
    [self updateScreenForType];
    
    [APP_CONTEXT makeRedButton:btnAdd];
    
    SSCheckBoxView * cbv = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(178, 79, 110, 30)
                                                          style:kSSCheckBoxViewStyleMono
                                                        checked:NO];
    [cbv setText:@"показать"];
    [cbv setStateChangedTarget:self selector:@selector(togglePasswordDisplay:)];
    [self.view addSubview:cbv];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateCheckPeriodTitle];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Настройки доступа"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
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
    
    //trim username
    NSString * username = [tfUsername.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    tfUsername.text = username;
    
    if ([tfUsername.text length] < 1)
    {
        [APP_CONTEXT showToastWithText:[NSString stringWithFormat:@"Введите %@", [[self loginTitle] lowercaseString]]];
        return;
    }
    
    NSInteger type = [accountType.id integerValue];
    BOOL isPhone = (type == kAccountMts || type == kAccountVelcom || type == kAccountLife || type == kAccountDiallog);
    
    if (isPhone)
    {
        NSInteger usernameLen = [tfUsername.text length];
        if (type == kAccountMts)
        {
            if (usernameLen < 7)
            {
                [APP_CONTEXT showToastWithText:@"Введите 9 цифр для номера телефона. 7 и более цифр для интернет-cчёта"];
                return;
            }
        }
        else
        {
            if (usernameLen != 9)
            {
                [APP_CONTEXT showToastWithText:@"Введите 9 цифр в номер телефона"];
                return;
            }
        }
    }
    
    if ([tfPassword.text length] < 1)
    {
        [APP_CONTEXT showToastWithText:[NSString stringWithFormat:@"Введите %@", [[self passwordTitle] lowercaseString]]];
        return;
    }
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    if (editMode)
    {
        account.username = tfUsername.text;
        account.password = tfPassword.text;
        account.label = tfLabel.text;
        account.periodicCheck = [NSNumber numberWithInt:currPeriodicCheck];
        account.balanceLimit = [PRIMITIVE_HELPER numberDecimalValue:tfBalanceLimit.text];
        [APP_CONTEXT saveDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnAccountsListUpdated object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [APP_CONTEXT showToastWithText:@"Аккаунт обновлён"];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"account"
                                                              action:@"account_update"
                                                               label:[NSString stringWithFormat:@"%@", account.type.name]
                                                               value:nil] build]];
    }
    else
    {
        BBMAccount * newAccount = [BBMAccount createEntity];
        newAccount.type = accountType;
        newAccount.username = tfUsername.text;
        newAccount.password = tfPassword.text;
        newAccount.label = tfLabel.text;
        newAccount.order = [BBMAccount nextOrder];
        newAccount.periodicCheck = [NSNumber numberWithInt:currPeriodicCheck];
        
        newAccount.balanceLimit = [PRIMITIVE_HELPER numberDecimalValue:tfBalanceLimit.text];
        
        [APP_CONTEXT saveDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnAccountsListUpdated object:nil];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        [APP_CONTEXT showToastWithText:@"Новый аккаунт добавлен"];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"account"
                                                              action:@"account_create"
                                                               label:[NSString stringWithFormat:@"%@", newAccount.type.name]
                                                               value:nil] build]];
    }
}

- (IBAction) togglePasswordDisplay:(id) sender
{
    [tfPassword resignFirstResponder];
    tfPassword.secureTextEntry = ![sender checked];
}

- (IBAction) openContacts:(id) sender
{
    ABPeoplePickerNavigationController * picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}


#pragma mark - Private

- (void) updateScreenForType
{
    NSInteger type = [accountType.id integerValue];
    cellPhone = NO;
    if (type == kAccountMts || type == kAccountVelcom || type == kAccountLife || type == kAccountDiallog)
    {
        cellPhone = YES;
    }
    
    lblUsername.text = [self loginTitle];
    lblPassword.text = [self passwordTitle];

    if (cellPhone)
    {
        lblUsernamePrefix.hidden = NO;
        tfUsername.frame = CGRectMake(85, 40, 162, 31);
        tfUsername.keyboardType = UIKeyboardTypeNumberPad;
        btnContacts.hidden = NO;
        
        
    }
    else
    {
        lblUsernamePrefix.hidden = YES;
        tfUsername.frame = CGRectMake(35, 40, 251, 31);
        if (type == kAccountBn) tfUsername.keyboardType = UIKeyboardTypeNumberPad;
        else if (type == kAccountByFly || type == kAccountDamavik || type == kAccountSolo || type == kAccountTeleset || type == kAccountAtlantTelecom) tfUsername.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        else tfUsername.keyboardType = UIKeyboardTypeDefault;
        btnContacts.hidden = YES;
    }
    
    if (editMode)
    {
        tfUsername.text = account.username;
        tfPassword.text = account.password;
        tfLabel.text = account.label;
        tfBalanceLimit.text  = [account.balanceLimit floatValue] > 0.0f ? [account.balanceLimit stringValue] : @"";
        
        [btnAdd setTitle:@"Сохранить" forState:UIControlStateNormal];
    }
    
    [self updateCheckPeriodTitle];
}

- (void) updateCheckPeriodTitle
{
    tfCheckType.text = [[BALANCE_CHECKER checkPeriodTypes] objectAtIndex:currPeriodicCheck];
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
        if (type == kAccountBn || type == kAccountDamavik || type == kAccountSolo || type == kAccountTeleset || type == kAccountAtlantTelecom) return @"Номер счёта";
        if (type == kAccountByFly || type == kAccountNetBerry || type == kAccountInfolan) return @"Номер договора";
        if (type == kAccountTcm || type == kAccountNiks || type == kAccountCosmosTv || type == kAccountUnetBy || type == kAccountAnitex) return @"Логин";
    }
    
    return @"";
}

- (NSString *) passwordTitle
{
    NSInteger type = [accountType.id integerValue];
    
    if (type == kAccountInfolan)
    {
        return @"Код авторизации";
    }
    
    return @"Пароль";
}

- (void) displayPersonPhone:(ABRecordRef)person
{
    //NSString * name = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    //self.firstName.text = name;
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0)
    {
        phone = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, 0));
    }
    else
    {
        phone = @"[нет]";
        
    }
    
    tfUsername.text = phone;
    
    CFRelease(phoneNumbers);
}


- (void) keyboardDidShow:(NSNotification *)notification
{
    [self moveFormUp];
}

- (void) keyboardDidHide:(NSNotification *)notification
{
    [self placeFormNormal];
}

- (void) moveFormUp
{
    CGFloat y = 0;
    if ([tfLabel isFirstResponder]) y = -50;
    else if ([tfBalanceLimit isFirstResponder]) y = -164;
    else return;
    
    //[self.view setFrame:CGRectMake(0, -50, 320, 416)];
    
    [UIView beginAnimations:@"moveFormUp" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.3];
    self.view.transform = CGAffineTransformMakeTranslation(0, y);
    [UIView commitAnimations];
    
    isFormUp = YES;

}

- (void) placeFormNormal
{
    if (!isFormUp) return;
    //[self.view setFrame:CGRectMake(0, 0, 320, 416)];
    
    [UIView beginAnimations:@"moveFormDown" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.3];
    self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView commitAnimations];
}

- (void) openSelectCheckPeriod
{
    [tfBalanceLimit resignFirstResponder];
    [self placeFormNormal];
    
    BBSelectCheckPeriodVC * vc = NEWVCFROMNIB(BBSelectCheckPeriodVC);
    vc.currPeriodicCheck = currPeriodicCheck;
    [self.navigationController pushViewController:vc animated:YES];
    //[self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == tfCheckType)
    {
        [self openSelectCheckPeriod];
        return NO;
    }
    return YES;
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{

    return YES;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    
    if (property == kABPersonPhoneProperty)
    {
        ABMultiValueRef numbers = ABRecordCopyValue(person, property);
        NSString * targetNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(numbers, ABMultiValueGetIndexForIdentifier(numbers, identifier)));
        
        DDLogInfo(@"%@", targetNumber);
       
        NSString * phone = [NSString stringWithFormat:@"%@", targetNumber];
        phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
        
        if ([phone hasPrefix:@"375"]) phone = [phone substringFromIndex:3];
        else if ([phone hasPrefix:@"802"]) phone = [phone substringFromIndex:2];
            
        tfUsername.text = [NSString stringWithFormat:@"%@", phone];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

#pragma mark - ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController
shouldPerformDefaultActionForPerson:(ABRecordRef)person
                  identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

@end
