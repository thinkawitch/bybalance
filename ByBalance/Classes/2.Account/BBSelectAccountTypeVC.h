//
//  BBSelectAccountTypeVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 04/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBSelectAccountTypeVC : BBBaseViewController
<UITableViewDataSource, UITableViewDelegate>
{
@private
    IBOutlet UITableView * tblAccountTypes;
}

@end
