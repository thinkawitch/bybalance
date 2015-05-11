//
//  TodayViewController.m
//  Today
//
//  Created by Andrew Sinkevitch on 25.02.15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "TodayViewController.h"
#import "BBTodayCell.h"

static NSString * cellId1 = @"BBTodayCellID";
static NSString * nib1 = @"BBTodayCell";

@interface TodayViewController () <NCWidgetProviding, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel * lblSelect;
@property (weak, nonatomic) IBOutlet UITableView * tblAccounts;

- (void) userDefaultsDidChange:(NSNotification *)notification;
- (void) updateScreen;

@end


@implementation TodayViewController

@synthesize lblSelect;
@synthesize tblAccounts;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [tblAccounts registerNib:[UINib nibWithNibName:nib1 bundle:nil] forCellReuseIdentifier:cellId1];
    
    [self updateScreen];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
     */
}


- (IBAction) openMainApp: (id)sender
{
    NSURL *url = [NSURL URLWithString:@"ByBalance://"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction) updateAccounts: (id)sender
{
    /*
    AppGroupSettings * gs = [AppGroupSettings sharedAppGroupSettings];
    [gs load];
    gs.updateBegin = arc4random_uniform(1000);
    gs.updateEnd = 0;
    [gs save];
     */

    /*
    NSString * token = [SETTINGS apnToken];
    AFHTTPRequestOperationManager * httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kApnServerUrl]];
    
    if ([oldToken isEqualToString:newToken] || [oldToken length] < 1)
    {
        //add token
        NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:newToken, @"token", kApnServerEnv, @"env", nil];
        
        [httpClient POST:@"add_token/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            SETTINGS.apnToken = newToken;
            [SETTINGS save];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            DDLogError(@"%s httpclient_error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }];
    }
    */
    
}



- (void) userDefaultsDidChange:(NSNotification *)notification
{
    NSLog(@"widget userDefaultsDidChange");
    [self updateScreen];
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
        self.preferredContentSize = tblAccounts.contentSize;
    }
    else
    {
        tblAccounts.hidden = YES;
        
        self.preferredContentSize = CGSizeMake(320, 40);
        lblSelect.hidden = NO;
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
    //margins.left = 18.0;
    margins.bottom = 4.0;
    return margins;
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

@end
