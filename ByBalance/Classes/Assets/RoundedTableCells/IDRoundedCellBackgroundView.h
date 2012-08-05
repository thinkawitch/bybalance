//
//  IDRoundedCellBackgroundView.h
//  idevs helpder for table cells with custom round corners
//
//  Updated by Andrew Sinkevitch
//
//  Created by Mike Akers on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  
{
    IDTableCellPositionTop, 
    IDTableCellPositionMiddle, 
    IDTableCellPositionBottom,
    IDTableCellPositionSingle,
    IDTableCellPositionPlain
} IDTableCellPosition;

@interface IDRoundedCellBackgroundView : UIView 
{
    UIColor * borderColor;
    UIColor * fillColor;
    IDTableCellPosition position;
}

@property(nonatomic, retain) UIColor * borderColor;
@property(nonatomic, retain) UIColor * fillColor;
@property(nonatomic) IDTableCellPosition position;

@end