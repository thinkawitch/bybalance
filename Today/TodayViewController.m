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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self updateScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

- (IBAction) openMainApp: (id)sender
{
    NSURL *url = [NSURL URLWithString:@"ByBalance://"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (void) userDefaultsDidChange:(NSNotification *)notification
{
    [self updateScreen];
}

- (void) updateScreen
{
    [[AppGroupSettings sharedAppGroupSettings] load];
    NSArray * records = [[AppGroupSettings sharedAppGroupSettings] accounts];
    if ([records count] < 1)
    {
        self.lblNoAccounts.text = @"Выберите записи для виджета";
        return;
    }
    
    NSMutableString * ms = [NSMutableString stringWithString:@""];
    for (NSDictionary * rec in records)
    {
        [ms appendFormat:@"%@ - %@ - %@\n", [rec valueForKey:@"name"], [rec valueForKey:@"balance"], [rec valueForKey:@"date"]];
    }
    
    self.lblNoAccounts.text = ms;
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
