//
//  BBAboutCell.h
//  ByBalance
//
//  Created by Admin on 02.06.13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBAboutCell : UITableViewCell
{
    IBOutlet UILabel * lblTitle;
}

- (void) setTitle:(NSString *) title;

@end
