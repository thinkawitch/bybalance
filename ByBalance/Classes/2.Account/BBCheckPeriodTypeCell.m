//
//  BBCheckPeriodTypeCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/30/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBCheckPeriodTypeCell.h"

@implementation BBCheckPeriodTypeCell

- (void) setupWithTitle:(NSString *)title selected:(BOOL) selected
{
    lblTitle.text = title;
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
