//
//  SCRCameraViewController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/13/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import "UtilityFunctions.h"
#import "SCRLastFM.h"
#import "SCRCameraViewController.h"

@interface SCRCameraViewController ()

@property SCRLastFM *lastFM;

@end

// Dummy controller right now
@implementation SCRCameraViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    
    // NSString *cssid = self.goggles.generateCSSID;
    // NSLog(@"Got cssid: %@...", cssid);
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    // Pick most relevant match
    NSDictionary *albumDict = [albumMatches objectAtIndex:0];
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