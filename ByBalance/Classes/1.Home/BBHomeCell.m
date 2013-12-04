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
- (CGFloat) labelTextWidth:(UILabel *)label;
@end

@implementation BBHomeCell

@synthesize vCircle;

@synthesize account;

- (void) setupWithAccount:(BBMAccount*) anAccount;
{
    self.account = anAccount;
    
    lblType.text = account.type.name;
    lblName.text = account.nameLabel;
    
    lblDate.text = [account lastGoodBalanceDate];
    lblBalance.text = [account lastGoodBalanceValue];
    
    BBMBalanceHistory * h = [account lastGoodBalance];
    
    if ([account.balanceLimit doubleValue] > 0 && [account.balanceLimit doubleValue] > [h.balance doubleValue])
    {
        if (!self.vCircle)
        {
            self.vCircle = [APP_CONTEXT circleWithColor:[APP_CONTEXT colorRed] radius:7];
            [self.contentView addSubview:vCircle];
        }
        
        CGFloat textWidth = [self labelTextWidth:lblBalance];
        CGFloat circleX = lblBalance.frame.origin.x + lblBalance.frame.size.width - textWidth - 17;
        vCircle.frame = CGRectMake(circleX, 42.5f, vCircle.frame.size.width, vCircle.frame.size.height);
    }
    else
    {
        [self.vCircle removeFromSuperview];
        self.vCircle = nil;
    }
}

- (CGFloat) labelTextWidth:(UILabel *)label
{
    
    //return [label.text sizeWithFont:[UIFont systemFontOfSize:17 ]].width;
    
    if (APP_CONTEXT.isIos7)
    {
        /*
        CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                                            options:NSStringDrawingTruncatesLastVisibleLine
                                                         attributes:@{
                                                                      NSFontAttributeName: label.font.familyName
                                                                      }
                                                            context:nil];
        
        
        CGSize maximumLabelSize = CGSizeMake(310, CGFLOAT_MAX);
         */
        CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                                 options:(NSStringDrawingTruncatesLastVisibleLine)
                                              attributes:@{NSFontAttributeName:label.font}
                                                 context:nil];
        
        return expectedLabelSize.size.width;
    }
    else
    {
        CGSize expectedLabelSize = [label.text sizeWithFont:label.font
                                          constrainedToSize:label.frame.size
                                              lineBreakMode:label.lineBreakMode];
        return expectedLabelSize.width;
    }
}

@end
