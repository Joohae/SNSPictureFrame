//
//  RootTableViewController.m
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 10..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <SNSServices/SNSServiceManager.h>

#import "RootTableViewController.h"
#import "DisplayViewController.h"

const NSString *kMainTableCell = @"MAIN_TABLE_CELL";
const NSString *kSecondSectionCell = @"SECOND_SECTION_CELL";

@interface RootTableViewController ()

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SNSServiceManager.numberOfServices;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString *_Nonnull)kMainTableCell forIndexPath:indexPath];

    NSDictionary *snsService = [SNSServiceManager getServiceAt:indexPath.row];
    [cell.textLabel setText:snsService[SNSServiceTitle]];
    [cell.detailTextLabel setText:snsService[SNSServiceDescription]];
    [cell.imageView setImage:[UIImage imageNamed:snsService[SNSServiceIcon]]];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    DisplayViewController *dvc = [segue destinationViewController];
    dvc.message = sender.textLabel.text;
}
// */

-(IBAction)returned:(UIStoryboardSegue *)sender {
    NSLog(@"Return from Segue");
}

@end
