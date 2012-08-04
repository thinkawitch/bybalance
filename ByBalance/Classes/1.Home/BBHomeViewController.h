//
//  BBViewController.h
//  ByBalance
//
//  Created by Lion User on 17/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBHomeViewController : BBBaseViewController <BBLoaderDelegate>
{
    
@private
    IBOutlet UITextView * textView;
    
}

- (IBAction) update:(id)sender;

@end
