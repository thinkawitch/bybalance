//
//  BBCheckPeriodTypeCell.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/30/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

@interface BBCheckPeriodTypeCell : UITableViewCell
{
    
@private
    IBOutlet UILabel * lblTitle;
    NSInteger periodType;
}

- (void) setupWithTitle:(NSString *)title selected:(BOOL) selected;

@end