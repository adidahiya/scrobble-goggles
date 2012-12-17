//
//  SCRAlbumResultsController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/17/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import "UtilityFunctions.h"
#import "SCRLastFM.h"
#import "SCRAlbumResultsController.h"

@interface SCRAlbumResultsController ()

@property SCRLastFM *lastFM;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    
    NSDictionary *album = [self.albums objectAtIndex:indexPath.row];
    [self.lastFM scrobbleAlbum:[album objectForKey:@"name"]
                      byArtist:[album objectForKey:@"artist"]];

    self.albums = [[NSArray alloc] init];
    [self.tableView reloadData];
}

// Interact with Last.fm API ===================================================

- (void) queryLastFM:(NSString *)album
{
    NSString *username = [UtilityFunctions retrieveFromUserDefaults:@"username"];
    NSString *password = [UtilityFunctions retrieveFromUserDefaults:@"password"];
    
    self.lastFM = [[SCRLastFM alloc] init];
    [self.lastFM initUser:username withPassword:password];
    
    NSArray *albumMatches = [self.lastFM getAlbumMatches:album];
    
    if ([albumMatches count] == 0) {
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
    // TODO
    NSLog(@"showResults called with (%@)", results);
    
    // Regex this shit
    NSString *pattern = @"\n[.*](Product)";
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionSearch
                                  error:nil];
    
    NSArray *matches = [regex matchesInString:results
                                      options:NSRegularExpressionSearch
                                        range:NSMakeRange(0, [results length])];
    
    NSLog(@"*********** %d regex matches *********", [matches count]);
    for (NSTextCheckingResult *match in matches) {
        NSLog(@"match: %@", [results substringWithRange:[match range]]);
    }
    
    [self queryLastFM:@"The Beatles Rubber Soul"];
}


@end
