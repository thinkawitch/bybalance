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
    
    NSInteger accountType;
}


- (void) setupWithAccountType:(BBMAccountType*) type;
- (NSInteger) accountType;

@end
