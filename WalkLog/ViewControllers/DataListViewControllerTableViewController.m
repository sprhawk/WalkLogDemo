//
//  DataListViewControllerTableViewController.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-8.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "DataListViewControllerTableViewController.h"
#import "DataCenter.h"

@interface DataListViewControllerTableViewController ()
{
    NSInteger _locationsCount;
}

@property (nonatomic, strong, readwrite) NSMutableSet *observers;
@end

@implementation DataListViewControllerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LocationCell"];
    
    __weak DataListViewControllerTableViewController *SELF = self;
    id observer;
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:DataCenterDidInsertLocationNotification
                                                                 object:nil
                                                                  queue:nil
                                                             usingBlock:^(NSNotification *note) {
                                                                 NSIndexPath *i = [NSIndexPath indexPathForRow:0 inSection:0];
                                                                 [SELF.tableView insertRowsAtIndexPaths:@[i] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                             }];
    [self.observers addObject:observer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    for (id o in self.observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:o];
    }
    [self.observers removeAllObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    _locationsCount = [[DataCenter sharedCenter] locationsCount];
    return _locationsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    BOOL foreground;
    CLLocation *loc = [[DataCenter sharedCenter] locationAtIndex:indexPath.row isForeground:&foreground];
    // Configure the cell...
    UILabel *l = (UILabel *)[cell.contentView viewWithTag:1];
    l.text = [NSString stringWithFormat:@"(%d:%@)lat:%f lon:%f (acc:%f)\nalt:%f (acc:%f)\ncourse:%f speed:%f",
              (int)(_locationsCount - indexPath.row), foreground?@"f":@"b",
              loc.coordinate.latitude, loc.coordinate.longitude, loc.horizontalAccuracy,
              loc.altitude, loc.verticalAccuracy, loc.course, loc.speed];
    l = (UILabel *)[cell.contentView viewWithTag:2];
    l.text = [NSString stringWithFormat:@"%@", loc.timestamp];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
