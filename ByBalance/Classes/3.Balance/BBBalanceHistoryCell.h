//
//  BBBalanceHistoryCell.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBBalanceHistoryCell : UITableViewCell
{
    
@private
    IBOutlet UILabel * lblDate;
    IBOutlet UILabel * lblBalance;
    
    BBMBalanceHistory * history;
}

@property (strong, nonatomic) BBMBalanceHistory * history;

- (void) setupWithHistory:(BBMBalanceHistory *) history;

@end
