//
//  BBSelectCheckPeriodVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/30/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBSelectCheckPeriodVC.h"
#import "BBCheckPeriodTypeCell.h"
#import "BBAccountFormVC.h"

@interface BBSelectCheckPeriodVC ()

@end

@implementation BBSelectCheckPeriodVC

@synthesize currPeriodicCheck;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[tblPeriodChecks setSeparatorColor:[UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1]];
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
    titleView.text = @"Проверять";
    [titleView sizeToFit];
}

#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * arr = [BALANCE_CHECKER checkPeriodTypes];
    return [arr count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"BBCheckTPeriodypeCellID";
    NSArray * nibs;
    
    BBCheckPeriodTypeCell * cell = (BBCheckPeriodTypeCell*)[tblPeriodChecks dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        nibs = [[NSBundle mainBundle] loadNibNamed:@"BBCheckPeriodTypeCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    
    NSInteger checkPeriodType = indexPath.row;
    NSString * title = [[BALANCE_CHECKER checkPeriodTypes] objectAtIndex:checkPeriodType];
    BOOL selected = (currPeriodicCheck == checkPeriodType);
    
    [cell setupWithTitle:title selected:selected];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kAccountTypeCellHeight;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBAccountFormVC * vc = (BBAccountFormVC *)[self backViewController];
    vc.currPeriodicCheck = indexPath.row;
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
