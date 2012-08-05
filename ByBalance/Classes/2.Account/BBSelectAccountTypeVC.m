//
//  BBAddAccountViewController.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 04/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBAddAccountViewController.h"

@interface BBAddAccountViewController ()

@end

@implementation BBAddAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    UIBarButtonItem * btnInfo = [APP_CONTEXT buttonFromName:@"arrow_left"];
    [(UIButton *)btnInfo.customView addTarget:self action:@selector(onNavButtonLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = btnInfo;    
    //title
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView.text = @"Добавить аккаунт";
    [titleView sizeToFit];
    
}

#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
