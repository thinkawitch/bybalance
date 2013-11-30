//
//  BBSelectCheckPeriodVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/30/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBSelectCheckPeriodVC : BBBaseViewController
<UITableViewDataSource, UITableViewDelegate>
{
@private
    IBOutlet UITableView * tblPeriodChecks;
}

@property (assign, nonatomic) NSInteger currPeriodicCheck;

@end
