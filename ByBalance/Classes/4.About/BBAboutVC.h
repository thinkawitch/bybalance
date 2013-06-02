//
//  BBAboutVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 09/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BBAboutVC : BBBaseViewController
<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
@private
    IBOutlet UILabel * lblVersion;
    IBOutlet UITableView * tblButtons;
}
@end
