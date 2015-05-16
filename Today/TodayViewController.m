//
//  TodayViewController.m
//  Today
//
//  Created by Andrew Sinkevitch on 25.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "TodayViewController.h"
#import "BBTodayCell.h"
#import <QuartzCore/QuartzCore.h>

static NSString * cellId1 = @"BBTodayCellID";
static NSString * nib1 = @"BBTodayCell";

@interface TodayViewController () <NCWidgetProviding, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate>
{
    NSTimer * uaTimer;
    CFTimeInterval uaStartTime;
    CGFloat uaTimerLimit;
    UIActivityIndicatorView * uaAiv;
    BOOL isUpdating;
}
@property (weak, nonatomic) IBOutlet UILabel * lblSelect;
@property (weak, nonatomic) IBOutlet UITableView * tblAccounts;
@property (weak, nonatomic) IBOutlet UIButton * btnUpdate;

- (void) updateScreen;

- (void) startUaTimer; //timer to check the progress of update accounts request
- (void) stopUaTimer;
- (void) onUaTimerTick:(NSTimer *)timer;
- (void) showActivityIndicator;
- (void) hideActivityIndicator;

- (UIImage *) imageWithColor:(UIColor *)color;

@end


@implementation TodayViewController

@synthesize lblSelect;
@synthesize tblAccounts;
@synthesize btnUpdate;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [tblAccounts registerNib:[UINib nibWithNibName:nib1 bundle:nil] forCellReuseIdentifier:cellId1];
    
    [btnUpdate setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:179.f/255.f green:0.f/255.f blue:0.f/255.f alpha:1.f]] forState:UIControlStateHighlighted];
    btnUpdate.layer.cornerRadius = 4;
    btnUpdate.clipsToBounds = YES;
    
    [self updateScreen];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopUaTimer];
    [super viewWillDisappear:animated];
}

- (void) updateScreen
{
    [GROUP_SETTINGS load];
    NSArray * records = [GROUP_SETTINGS accounts];
    
    if ([records count] > 0)
    {
        lblSelect.hidden = YES;
        
        tblAccounts.hidden = NO;
        [tblAccounts reloadData];
        if (isUpdating) [self showActivityIndicator];
        else btnUpdate.hidden = NO;
        
        //self.preferredContentSize = tblAccounts.contentSize;
        self.preferredContentSize = CGSizeMake(tblAccounts.contentSize.width, tblAccounts.contentSize.height + 25.f);
    }
    else
    {
        tblAccounts.hidden = YES;
        btnUpdate.hidden = YES;
        lblSelect.hidden = NO;
        
        self.preferredContentSize = CGSizeMake(320, 40);
    }
}

#pragma mark - Actions

- (IBAction) openMainApp: (id)sender
{
    NSURL *url = [NSURL URLWithString:@"ByBalance://"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction) updateAccounts: (id)sender
{
    //NSLog(@"widget updateAccounts");
    //uaTimerLimit = [[GROUP_SETTINGS accounts] count] * 7.f; // 7 secs per account
    //[self startUaTimer];
    //return;
    
    [GROUP_SETTINGS load];
    NSString * apnToken = GROUP_SETTINGS.apnToken;
    if (!apnToken || [apnToken isEqualToString:@""])
    {
        NSLog(@"widget empty apnToken: %@", apnToken);
        return;
    }
    
    NSString * link = [NSString stringWithFormat:@"%@update/%@/%@", kApnServerUrl, kApnServerEnv, apnToken];
    //NSLog(@"widget link: %@", link);
    NSURL * url = [NSURL URLWithString:link];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    uaTimerLimit = [[GROUP_SETTINGS accounts] count] * 7.f; // 7 secs per account
    [self startUaTimer];
}

#pragma mark - Update accounts timer

- (void) startUaTimer
{
    isUpdating = YES;
    if (uaTimer) [self stopUaTimer];
    
    uaTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                target:self
                                              selector:@selector(onUaTimerTick:)
                                              userInfo:nil
                                               repeats:YES];
    uaStartTime = CACurrentMediaTime();
    
    [self showActivityIndicator];
    btnUpdate.hidden = YES;
}

- (void) stopUaTimer
{
    if (uaTimer)
    {
        [uaTimer invalidate];
        uaTimer = nil;
    }
    
    [self hideActivityIndicator];
    
    btnUpdate.hidden = NO;
    isUpdating = NO;
}

- (void) onUaTimerTick:(NSTimer *)timer
{
    CFTimeInterval elapsedTime = CACurrentMediaTime() - uaStartTime;
    
    if (elapsedTime > uaTimerLimit)
    {
        [self stopUaTimer];
    }
    
    [self updateScreen];
}

- (void) showActivityIndicator
{
    [self hideActivityIndicator];
    
    uaAiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //uaAiv.color = [UIColor colorWithRed:229.f/255.f green:20.f/255.f blue:13.f/255.f alpha:1.f];
    uaAiv.color = [UIColor darkGrayColor];
    uaAiv.hidesWhenStopped = YES;
    [self.view addSubview:uaAiv];
    //uaAiv.center = CGPointMake(btnUpdate.frame.origin.x - 20.f, btnUpdate.frame.origin.y + 10.f);
    uaAiv.center = btnUpdate.center;
    [uaAiv startAnimating];
}

- (void) hideActivityIndicator
{
    if (uaAiv)
    {
        [uaAiv removeFromSuperview];
        uaAiv = nil;
    }
}

#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self updateScreen];
    
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.left = 18.0;
    margins.bottom = 4.0;
    return margins;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"didReceiveResponse %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"didReceiveData %@", data);
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"connection result: %@", result);
    if ([result rangeOfString:@"push_sent"].location == NSNotFound)
    {
        //not sent
        [self stopUaTimer];
        return;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 21.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * records = [GROUP_SETTINGS accounts];
    return [records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * records = [GROUP_SETTINGS accounts];
    NSDictionary * record = [records objectAtIndex:indexPath.row];
    
    BBTodayCell * cell = (BBTodayCell*)[tableView dequeueReusableCellWithIdentifier:cellId1];
    cell.backgroundColor = [UIColor clearColor];
    [cell setupWithDictionary:record];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - Miscs

- (UIImage *) imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
