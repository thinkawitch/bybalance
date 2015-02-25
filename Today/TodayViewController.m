//
//  TodayViewController.m
//  Today
//
//  Created by Andrew Sinkevitch on 25.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel * lblNoAccounts;

- (void) userDefaultsDidChange:(NSNotification *)notification;
- (void) updateScreen;

@end

@implementation TodayViewController

/*
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}
 */

- (void) viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"viewDidLoad");
    
    [self updateScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction) openMainApp: (id)sender
{
    NSLog(@"openMainApp");
    NSURL *url = [NSURL URLWithString:@"ByBalance://"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (void) userDefaultsDidChange:(NSNotification *)notification
{
    NSLog(@"userDefaultsDidChange");
    NSLog(@"%@", notification);
    
    [self updateScreen];
}

- (void) updateScreen
{
    NSLog(@"updateScreen");
    [[AppGroupSettings sharedAppGroupSettings] load];
    NSArray * accounts = [[AppGroupSettings sharedAppGroupSettings] accounts];
    NSLog(@"accounts %@", accounts);
    
    self.lblNoAccounts.text = [NSString stringWithFormat:@"accounts: %d", [accounts count]];
}

#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    //[self updateScreen];
    
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 4.0;
    return margins;
}

@end
