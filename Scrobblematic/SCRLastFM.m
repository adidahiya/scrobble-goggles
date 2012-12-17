//
//  SCRLastFM.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/17/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import "SCRLastFM.h"

@interface SCRLastFM ()

@property NSString *authToken;
@property NSString *username;
@property FMEngine *fmEngine;

@end

@implementation SCRLastFM

- (void) initUser:(NSString *)username withPassword:(NSString *)password
{
    // Handle nil usernames / passwords and show alert
    UIAlertView *alert;
    if (username == nil) {
        NSLog(@"Invalid username");
        alert = [[UIAlertView alloc] initWithTitle:@"Invalid Last.fm username"
                                           message:@"" delegate:nil
                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    } else if (password == nil) {
        NSLog(@"Invalid password");
        alert = [[UIAlertView alloc] initWithTitle:@"Invalid Last.fm password"
                                           message:@"" delegate:nil
                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    self.fmEngine = [[FMEngine alloc] init];

    self.username = username;
	self.authToken = [self.fmEngine generateAuthTokenFromUsername:username
                                                         password:password];
	NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             username, @"username",
                             self.authToken, @"authToken",
                             _LASTFM_API_KEY_, @"api_key",
                             nil, nil];

	[self.fmEngine performMethod:@"auth.getMobileSession" withTarget:self
                  withParameters:urlDict andAction:@selector(loginCallback:data:)
                    useSignature:YES httpMethod:POST_TYPE];
}

- (void) loginCallback:(NSString *)identifier data:(id)data {
	// data is either NSData or NSError
	NSLog(@"Got Data (%@): %@", identifier, data);
    NSLog(@"Maybe auth token? %@", self.authToken);
}

- (NSArray *) getAlbumMatches:(NSString *)album
{
    NSDictionary *searchParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                  _LASTFM_API_KEY_, @"api_key",
                                  album, @"album",
                                  nil, nil];

    NSData *data = [self.fmEngine dataForMethod:@"album.search"
                                    withParameters:searchParams
                                      useSignature:YES httpMethod:POST_TYPE
                                             error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0
                                                           error:nil];
    NSArray *matches = [[[json objectForKey:@"results"]
                         objectForKey:@"albummatches"]
                        objectForKey:@"album"];

    NSLog(@"Got %d album match(es) for %@", [matches count], album);
    return matches;
}

@end
