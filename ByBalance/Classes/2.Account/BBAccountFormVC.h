//
//  BBAccountFormVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBAccountFormVC : BBBaseViewController <UITextFieldDelegate>
{
    
@private
    IBOutlet UILabel * lblUsername;
    IBOutlet UILabel * lblUsernamePrefix;
    IBOutlet UILabel * lblPassword;
    IBOutlet UITextField * tfUsername;
    IBOutlet UITextField * tfPassword;
    IBOutlet UIButton * btnAdd;
    
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

@end
