//
//  BBHomeVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBHomeVC : BBBaseViewController
<BBLoaderDelegate, UITableViewDataSource, UITableViewDelegate>
{
    
@private
    IBOutlet UITextView * textView;
    IBOutlet UITableView * tblAccounts;
    
    NSArray * accounts;
    BOOL needUpdateTable;
    
}

- (IBAction) update:(id)sender;

@end
