//
//  BBAboutVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 09/08/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBAboutVC.h"
#import "BBAboutCell.h"

@interface BBAboutVC ()

- (void) openBlog;
- (void) openAppPage;
- (void) openMessage;

@end

@implementation BBAboutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tblButtons setSeparatorColor:[UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1]];
    
    //lblVersion.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    lblVersion.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[[GAI sharedInstance] defaultTracker] sendView:@"Справка"];
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
    titleView.text = @"Справка";
    [titleView sizeToFit];
}

#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) openBlog
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://bybalance.wordpress.com"]];
}

- (void) openAppPage
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com/app/id568676131"]];
}

- (void) openMessage
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController * composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        [composer setToRecipients:[NSArray arrayWithObject:@"by.balance.app@gmail.com"]];
        [composer setSubject:@"Сообщение по БайБаланс"];
        [composer setMessageBody:@"Добрый день,\n" isHTML:NO];
        
        [self presentModalViewController:composer animated:YES];
    }
    else
    {
        [APP_CONTEXT showToastWithText:@"У вас не настроена почта"];
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"BBAboutCellID";
    NSArray * nibs;
    
    BBAboutCell * cell = (BBAboutCell*)[tblButtons dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        nibs = [[NSBundle mainBundle] loadNibNamed:@"BBAboutCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    
    switch (indexPath.row)
    {
        case 0:
            [cell setTitle:@"Блог приложения"];
            break;
            
        case 1:
            [cell setTitle:@"Оценить приложение"];
            break;
            
        case 2:
            [cell setTitle:@"Сообщение автору"];
            break;
    }
/*
    BBMAccount * account = [self.accounts objectAtIndex:indexPath.row];
    
    [cell setupWithAccount:account];
  */  
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kAboutCellHeight;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            [self openBlog];
            break;
            
        case 1:
            [self openAppPage];
            break;
            
        case 2:
            [self openMessage];
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller dismissModalViewControllerAnimated:YES];
}

@end
