//
//  BBHomeVC.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 17/06/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBHomeVC.h"
#import "BBSelectAccountTypeVC.h"

@interface BBHomeVC ()

@end

@implementation BBHomeVC

#pragma mark - ObjectLife

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    textView.text = [SETTINGS log];
    [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
}

#pragma mark - Setup

- (void) setupNavBar
{
    [super setupNavBar];
    
    UIBarButtonItem * spacer = [[UIBarButtonItem alloc] 
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                target:nil action:nil];
    spacer.width = 10; 
    
    //left button
    UIBarButtonItem * btnInfo = [APP_CONTEXT infoIconButton];
    [(UIButton *)btnInfo.customView addTarget:self action:@selector(onNavButtonLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:spacer, btnInfo, nil];
    
    //title
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView.text = @"ByBalance";
    [titleView sizeToFit];
    
    
    //right button
    //UIBarButtonItem * btnAdd = [APP_CONTEXT addIconButton];
    UIBarButtonItem * btnAdd = [APP_CONTEXT buttonFromName:@"key_add"];
    [(UIButton *)btnAdd.customView addTarget:self action:@selector(onNavButtonRight:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:spacer, btnAdd, nil];
}

#pragma mark - Actions

- (IBAction) onNavButtonLeft:(id)sender
{
    
}

- (IBAction) onNavButtonRight:(id)sender
{
    BBSelectAccountTypeVC * vc = NEWVCFROMNIB(BBSelectAccountTypeVC);
    //[[BBAddAccountViewController alloc] initWithNibName:@"BBAddAccountView" bundle:nil];
   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
}

#pragma mark - Logic

- (IBAction) update:(id)sender
{
    if (![APP_CONTEXT isOnline])
    {
        [APP_CONTEXT showAlertForNoInternet];
        return;
    }
    
    /*
    NSError * error = nil;
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"mts_balance" ofType:@"html"];
    
    NSString * str = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:&error];
    //NSLog(@"%@", str);
    */
    
    BBItemMts *item = [[BBItemMts new] autorelease];
    item.username = @"297527406";
    item.password = @"9068";
    
    BBLoaderBase * loader = [BBLoaderBase new];
    loader.item = item;
    loader.delegate = self;
    [loader start];
    
    [self showWaitIndicator:YES]; 
}

#pragma mark - BBLoaderDelegate

- (void) dataLoaderSuccess:(BBLoaderBase*)loader
{
    [self showWaitIndicator:NO];
    
    IDDateHelper * dh = [IDDateHelper sharedIDDateHelper];
    NSString * time = [dh dateToMysqlDateTime:[NSDate date]];
    textView.text = [textView.text stringByAppendingFormat:@"\r\n%@\r\n%@\r\n", time, loader.item.fullDescription];
    [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];

    [loader autorelease];
    
    SETTINGS.log = textView.text;
}

- (void) dataLoaderFail:(BBLoaderBase*)loader
{
    [self showWaitIndicator:NO];
    
    IDDateHelper * dh = [IDDateHelper sharedIDDateHelper];
    NSString * time = [dh dateToMysqlDateTime:[NSDate date]];
    textView.text = [textView.text stringByAppendingFormat:@"\r\n%@\r\n%@\r\n", time, loader.item.fullDescription];
    [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
    
    [loader autorelease];
    
    SETTINGS.log = textView.text;
}

@end
