//
//  SCRAlbumResultsController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/17/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import "SCRAlbumResultsController.h"

@interface SCRAlbumResultsController ()

@property NSArray *albums;

@end

@implementation SCRAlbumResultsController

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
    // Hard-coded to 1 section for now
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"albumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *album = [self.albums objectAtIndex:indexPath.row];

    UIImageView *image = (UIImageView *) [cell viewWithTag:0];
    UILabel *albumLabel = (UILabel *) [cell viewWithTag:1];
    UILabel *artistLabel = (UILabel *) [cell viewWithTag:2];
    
    // Get medium-sized image
    NSString *imageURL = [[[album objectForKey:@"image"] objectAtIndex:1]
                          objectForKey:@"#text"];

    albumLabel.text = [[album objectForKey:@"name"] capitalizedString];
    artistLabel.text = [album objectForKey:@"artist"];
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
    SCRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSDictionary *album = [self.albums objectAtIndex:indexPath.row];
    [appDelegate.lastFM scrobbleAlbum:[album objectForKey:@"name"]
                             byArtist:[album objectForKey:@"artist"]];

    // self.albums = [[NSArray alloc] init];
    [self.tableView reloadData];
}

// Interact with Last.fm API ===================================================

- (void) queryLastFM:(NSString *)album
{
    SCRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // Note: Last.fm search API is really stupid, so this might not return good
    // results
    NSArray *albumMatches = [appDelegate.lastFM getAlbumMatches:album];
    int numMatches = [albumMatches count];

    if (numMatches == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches for album!"
                                                        message:@"" delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.albums = albumMatches;
    [self.tableView reloadData];
}

// Handle Google Goggles results & update UI ===================================

- (void) showResults:(NSString *)results
{
    // NSLog(@"showResults called with results: ********(%@)********", results);

    // SO MUCH REGEX
    // \\x12 matches trailing ^R
    // leading hex shorts: ^O (x0f) ^Y (x19) ^U (x15) ^T (x14) ^] (x1d)
    //                     ^Q (x11) ^S (x13) ^N (x0e) ^Z (x1a) ^[ (\e)
    // other leading patterns: \t (single space), !,
    NSString *leadingGroup = @"(?:[\\s\\x0f\\x11\\x12\\x13\\x14\\x15\\x16\\x17\
                                   \\x18\\x19\\x1a\\x1b\\x1c\\x1d\\x1e\\x1f])";
    NSString *albumTitleGroup = @"([\\w\\s\\!\\-]+)";
    
    NSString *pattern = [NSString stringWithFormat: @"(?:\\n)%@%@(?:\\W*)(?:\\x12)",
                         leadingGroup, albumTitleGroup];
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionSearch
                                  error:nil];

    NSArray *matches = [regex matchesInString:results
                                      options:NSRegularExpressionSearch
                                        range:NSMakeRange(0, [results length])];

    NSLog(@"*********** %d regex matches *********", [matches count]);
    for (NSTextCheckingResult *match in matches) {
        // NSString *substr = [results substringWithRange:[match rangeAtIndex:1]];
        // NSLog(@"match: (%@)", substr);
    }
    
    if ([matches count]) {
        NSString *albumQuery = [results substringWithRange:
                                [[matches objectAtIndex:0] rangeAtIndex:1]];
        NSLog(@"album query: (%@)", albumQuery);
        [self queryLastFM:albumQuery];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Could not recognize album."
                              message:@"" delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    // [self queryLastFM:@"The Beatles Rubber Soul"];
}


@end
