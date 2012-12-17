//
//  SCRCameraViewController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/13/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//


#import "SCRCameraViewController.h"

@interface SCRCameraViewController ()

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

// Handle Google Goggles results & update UI ===================================

- (void) showResults:(NSString *)results
{
    // TODO
    // NSLog(@"showResults called with %@", results);
    
    // Regex this shit
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@":\s*"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    
    int matches = [regex numberOfMatchesInString:results
                                         options:NSRegularExpressionCaseInsensitive
                                           range:NSMakeRange(0, [results length])];
    
    NSLog(@"%d results matches with regex", matches);
}


@end
