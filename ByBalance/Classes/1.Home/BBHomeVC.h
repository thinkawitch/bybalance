//
//  BBHomeVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBHomeVC : BBBaseViewController
<UITableViewDataSource, UITableViewDelegate>
{
    
@private
    IBOutlet UITableView * tblAccounts;
    IBOutlet UIView * splashView;
    IBOutlet UIButton * btnBigAdd;
    
    NSMutableArray * accounts;
    
    IBOutlet UIToolbar * toolbar;
    
    UIButton * btnRefresh;
    UILabel * lblStatus;
    UIActivityIndicatorView * vActivity;
    UIButton * btnReorder;
}

- (IBAction) update:(id)sender;

@end
