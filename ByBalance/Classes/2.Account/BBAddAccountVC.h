//
//  BBAddAccountVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBAddAccountVC : BBBaseViewController <UITextFieldDelegate>
{
    
@private
    IBOutlet UILabel * lblUsername;
    IBOutlet UILabel * lblUsernamePrefix;
    IBOutlet UILabel * lblPassword;
    
    IBOutlet UITextField * tfUsername;
    IBOutlet UITextField * tfPassword;
    
    BBMAccountType * accountType;
    
}

@property (strong, nonatomic) BBMAccountType * accountType;

- (IBAction) add:(id) sender;
- (IBAction) hideKeyboard:(id) sender;

@end
