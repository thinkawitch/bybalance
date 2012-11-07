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
    IBOutlet UILabel * lblHistory;
    
    IBOutlet UIButton * btnRefresh;
    IBOutlet UIButton * btnClear;
    
    IBOutlet UITableView * tblHistory;
    
    BBMAccount * account;
    NSArray * history;
    
    NSInteger alertMode;
    NSInteger historyStay;
}

@property (strong,nonatomic) BBMAccount * account;

- (IBAction) onBtnRefresh:(id)sender;
- (IBAction) onBtnClear:(id)sender;

@end
