//
//  BBHomeCell.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBHomeCell : UITableViewCell
{
    
@private
    IBOutlet UILabel * lblType;
    IBOutlet UILabel * lblName;
    IBOutlet UILabel * lblDate;
    IBOutlet UILabel * lblBalance;
    IBOutlet UIView * vCircle;
    
    BBMAccount * account;
    BOOL ipadChangesApplied;
}

@property (strong, nonatomic) BBMAccount * account;

- (void) setupWithAccount:(BBMAccount*) account;

@end
