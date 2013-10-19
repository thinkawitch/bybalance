//
//  BBAccountFormVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface BBAccountFormVC : BBBaseViewController
<UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    
@private
    IBOutlet UILabel * lblUsername;
    IBOutlet UILabel * lblUsernamePrefix;
    IBOutlet UILabel * lblPassword;
    IBOutlet UITextField * tfUsername;
    IBOutlet UITextField * tfPassword;
    IBOutlet UITextField * tfLabel;
    IBOutlet UIButton * btnAdd;
    IBOutlet UIButton * btnContacts;
    
    BBMAccountType * accountType;
    BOOL editMode;
    BBMAccount * account;
    
    BOOL cellPhone;
}

@property (strong, nonatomic) BBMAccountType * accountType;
@property (assign, nonatomic) BOOL editMode;
@property (strong, nonatomic) BBMAccount * account;
@property (assign, nonatomic) BOOL cellPhone;

- (IBAction) add:(id) sender;
- (IBAction) hideKeyboard:(id) sender;
- (IBAction) togglePasswordDisplay:(id) sender;
- (IBAction) openContacts:(id) sender;

@end
