//
//  BBHomeVC.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBHomeVC : BBBaseViewController <BBLoaderDelegate>
{
    
@private
    IBOutlet UITextView * textView;
    
}

- (IBAction) update:(id)sender;

@end
