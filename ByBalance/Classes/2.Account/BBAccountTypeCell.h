//
//  BBAccountTypeCell.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 05/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

@class BBMAccountType;

@interface BBAccountTypeCell : UITableViewCell
{
    
@private
    IBOutlet UILabel * lblTitle;
    
    BBMAccountType * accountType;
    BOOL ipadChangesApplied;
}

@property (strong, nonatomic) BBMAccountType * accountType;

- (void) setupWithAccountType:(BBMAccountType*) type;

@end
