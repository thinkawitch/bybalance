//
//  BBAboutVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 09/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBAboutVC.h"

@interface BBAboutVC ()

@end

@implementation BBAboutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    lblVersion.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Setup

- (void) setupNavBar
{
    [super setupNavBar];
    
    
    //left button
    UIBarButtonItem * btnBack = [APP_CONTEXT buttonFromName:@"arrow_left"];
    [(UIButton *)btnBack.customView addTarget:self action:@selector(onNavButtonLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = btnBack;
    
    //title
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView.text = @"О программе";
    [titleView sizeToFit];
}

- (IBAction) onNavButtonLeft:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
