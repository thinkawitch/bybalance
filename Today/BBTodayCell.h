//
//  BBTodayCell.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 26.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTodayCell : UITableViewCell
{
@protected
    IBOutlet UILabel * lblName;
    IBOutlet UILabel * lblDate;
    IBOutlet UILabel * lblBalance;
}

- (void) setupWithDictionary:(NSDictionary *) dict;

@end
