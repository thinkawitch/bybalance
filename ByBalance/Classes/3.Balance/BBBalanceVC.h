//
//  BBBalanceVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 12/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBBalanceVC : BBBaseViewController
<UIAlertViewDelegate>
{
@private
    IBOutlet UILabel * lblType;
    IBOutlet UILabel * lblName;
    IBOutlet UILabel * lblDate;
    IBOutlet UILabel * lblBalance;
    IBOutlet UIButton * btnRefresh;
    
    BBMAccount * account;
}

@property (strong,nonatomic) BBMAccount * account;

@end
