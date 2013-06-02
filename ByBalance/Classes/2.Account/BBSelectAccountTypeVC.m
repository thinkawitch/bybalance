//
//  BBSelectAccountTypeVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 04/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBSelectAccountTypeVC.h"
#import "BBAccountTypeCell.h"
#import "BBAccountFormVC.h"

@interface BBSelectAccountTypeVC ()


@end

@implementation BBSelectAccountTypeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[tblAccountTypes setSeparatorColor:[UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[GAI sharedInstance] defaultTracker] sendView:@"Список компаний"];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * arr = [BBMAccountType findAll];
    return [arr count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"BBAccountTypeCellID";
    NSArray * nibs;
    
    BBAccountTypeCell * cell = (BBAccountTypeCell*)[tblAccountTypes dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        nibs = [[NSBundle mainBundle] loadNibNamed:@"BBAccountTypeCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    
    NSNumber * atId  = [NSNumber numberWithInt:indexPath.row + 1];
    BBMAccountType * at = [BBMAccountType findFirstByAttribute:@"id" withValue:atId];
    
    if (at)
    {
        [cell setupWithAccountType:at];
    }
    
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
    BBAccountTypeCell * cell = (BBAccountTypeCell *)[tblAccountTypes cellForRowAtIndexPath:indexPath];
    if (nil == cell)
    {
        NSAssert(0, @"%@. Cell is nil", [self class]);
        return;
    }
    
    BBAccountFormVC * vc = NEWVCFROMNIB(BBAccountFormVC);
    vc.accountType = cell.accountType;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}


@end
