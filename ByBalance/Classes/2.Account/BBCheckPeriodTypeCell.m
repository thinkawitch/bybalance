//
//  BBCheckPeriodTypeCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/30/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBCheckPeriodTypeCell.h"

@interface BBCheckPeriodTypeCell ()
- (void) applyIpadChanges;
@end

@implementation BBCheckPeriodTypeCell

- (void) setupWithTitle:(NSString *)title selected:(BOOL) selected
{
    [self applyIpadChanges];
    
    lblTitle.text = title;
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void) applyIpadChanges
{
    if (!APP_CONTEXT.isIpad || ipadChangesApplied) return;
    
    self.backgroundColor = [UIColor clearColor]; //universal app, ipad makes bg white
    
    ipadChangesApplied = YES;
}

@end
