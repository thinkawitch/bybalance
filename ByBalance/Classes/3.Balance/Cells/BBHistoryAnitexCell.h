//
//  BBHistoryAnitexCell.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/5/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBHistoryBaseCell.h"

@interface BBHistoryAnitexCell : BBHistoryBaseCell
{
    
@private
    IBOutlet UIView  * vPanel1;
    IBOutlet UILabel * lblDate;
    IBOutlet UILabel * lblMegabytes;
    IBOutlet UILabel * lblCredit;
    
    IBOutlet UIView * vPanel2;
    
}
@end
