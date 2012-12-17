//
//  SCRHistoryViewController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/17/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import "SCRHistoryViewController.h"

@interface SCRHistoryViewController ()

@property NSArray *tracks;

@end

@implementation SCRHistoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    SCRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate initLastFM];
    self.tracks = [appDelegate.lastFM getRecentScrobbles];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"trackCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    
    UIImageView *image = (UIImageView *) [cell viewWithTag:0];
    UILabel *trackLabel = (UILabel *) [cell viewWithTag:1];
    UILabel *artistLabel = (UILabel *) [cell viewWithTag:2];
    
    // Get medium-sized image
    NSString *imageURL = [[[track objectForKey:@"image"] objectAtIndex:1]
                          objectForKey:@"#text"];
    
    trackLabel.text = [[track objectForKey:@"name"] capitalizedString];
    artistLabel.text = [[track objectForKey:@"artist"] objectForKey:@"#text"];
    image.image = [UIImage imageWithData:
                   [NSData dataWithContentsOfURL:
                    [NSURL URLWithString:imageURL]]];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
