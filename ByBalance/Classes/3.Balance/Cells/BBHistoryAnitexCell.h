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
    IBOutlet UILabel * lblDate;
    IBOutlet UILabel * lblMegabytes;
    IBOutlet UILabel * lblDays;
    IBOutlet UILabel * lblCredit;
    
}
@end
