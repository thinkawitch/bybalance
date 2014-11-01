//
//  BBHomeCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBHomeCell.h"

@interface BBHomeCell ()
- (void) applyIpadChanges;
@end

@implementation BBHomeCell

@synthesize account;


- (void) setupWithAccount:(BBMAccount*) anAccount;
{
    [self applyIpadChanges];
    
    self.account = anAccount;
    
    lblType.text = account.type.name;
    lblName.text = account.nameLabel;
    
    lblDate.text = [account lastGoodBalanceDate];
    lblBalance.text = [account lastGoodBalanceValue];
    
    [APP_CONTEXT makeRedCircle:vCircle];
    
    vCircle.hidden = ![account balanceLimitCrossed];
}

- (void) applyIpadChanges
{
    if (!APP_CONTEXT.isIpad || ipadChangesApplied) return;
    
    self.backgroundColor = [UIColor clearColor]; //universal app, ipad makes bg white
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [APP_CONTEXT colorGrayDark];
    self.selectedBackgroundView = v;
    
    self.accessoryType = UITableViewCellAccessoryNone;
    
    CGRect frame = lblName.frame;
    lblName.frame = CGRectMake(frame.origin.x, frame.origin.y, 200.f, frame.size.height);
    
    ipadChangesApplied = YES;
}

@end
