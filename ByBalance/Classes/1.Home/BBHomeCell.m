//
//  BBHomeCell.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBHomeCell.h"

@interface BBHomeCell ()
@property (strong,nonatomic) UIView * vCircle;
- (void) applyIpadChanges;
@end

@implementation BBHomeCell

@synthesize vCircle;
@synthesize account;


- (void) setupWithAccount:(BBMAccount*) anAccount;
{
    [self applyIpadChanges];
    
    self.account = anAccount;
    
    lblType.text = account.type.name;
    lblName.text = account.nameLabel;
    
    lblDate.text = [account lastGoodBalanceDate];
    lblBalance.text = [account lastGoodBalanceValue];
    
    if ([account balanceLimitCrossed])
    {
        if (!self.vCircle)
        {
            self.vCircle = [APP_CONTEXT circleWithColor:[APP_CONTEXT colorRed] radius:3];
            [self.contentView addSubview:vCircle];
        }
        
        CGFloat textWidth = [APP_CONTEXT labelTextWidth:lblBalance];
        CGFloat circleX = lblBalance.frame.origin.x + lblBalance.frame.size.width - textWidth - vCircle.frame.size.width - 3;
        CGFloat circleY = lblBalance.frame.origin.y + (lblBalance.frame.size.height - vCircle.frame.size.height)/2;
        vCircle.frame = CGRectMake(circleX, circleY, vCircle.frame.size.width, vCircle.frame.size.height);
        
        //lblBalance.textColor = [APP_CONTEXT colorRed];
    }
    else
    {
        [self.vCircle removeFromSuperview];
        self.vCircle = nil;
        
        //lblBalance.textColor = [APP_CONTEXT colorGrayLight];
    }
    
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
