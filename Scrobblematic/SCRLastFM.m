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

    fmEngine = [[FMEngine alloc] init];

    self.username = username;
	self.authToken = [fmEngine generateAuthTokenFromUsername:username
                                                    password:password];
	NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             username, @"username",
                             self.authToken, @"authToken",
                             _LASTFM_API_KEY_, @"api_key",
                             nil, nil];

	[fmEngine performMethod:@"auth.getMobileSession" withTarget:self
             withParameters:urlDict andAction:@selector(loginCallback:data:)
               useSignature:YES httpMethod:POST_TYPE];
}

- (void) loginCallback:(NSString *)identifier data:(id)data {
	// data is either NSData or NSError
	// NSLog(@"Got Data (%@): %@", identifier, data);
    NSLog(@"Last.fm auth token: %@", self.authToken);
}

- (NSArray *) getAlbumMatches:(NSString *)album
{
    NSDictionary *searchParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                  _LASTFM_API_KEY_, @"api_key",
                                  album, @"album",
                                  nil, nil];

    NSData *data = [fmEngine dataForMethod:@"album.search"
                            withParameters:searchParams useSignature:YES
                                httpMethod:POST_TYPE error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0
                                                           error:nil];
    NSArray *matches = [[[json objectForKey:@"results"]
                         objectForKey:@"albummatches"]
                        objectForKey:@"album"];

    NSLog(@"Got %d album match(es) for %@", [matches count], album);
    return matches;
}

- (void) scrobbleTrack:(NSString *)track byArtist:(NSString *)artist
               onAlbum:(NSString *)album
{
    long timestamp = (long) [[NSDate date] timeIntervalSince1970];

    NSDictionary *scrobbleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    _LASTFM_API_KEY_, @"api_key",
                                    artist, @"artist",
                                    track, @"track",
                                    album, @"album",
                                    timestamp, @"timestamp",
                                    nil, nil];
    NSLog(@"Scrobbling: %@", scrobbleParams);
    NSData *data = [fmEngine dataForMethod:@"track.scrobble"
                            withParameters:scrobbleParams useSignature:YES
                                httpMethod:POST_TYPE error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0
                                                           error:nil];
    NSLog(@"Scrobble response: %@", json);
}

- (void) scrobbleAlbum:(NSString *)album byArtist:(NSString *)artist
{
    NSDictionary *albumInfoParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     _LASTFM_API_KEY_, @"api_key",
                                     artist, @"artist",
                                     album, @"album",
                                     nil, nil];
    NSData *data = [fmEngine dataForMethod:@"album.getInfo"
                            withParameters:albumInfoParams useSignature:NO
                                httpMethod:POST_TYPE error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0
                                                           error:nil];
    NSArray *tracks = [[[json objectForKey:@"album"] objectForKey:@"tracks"]
                       objectForKey:@"track"];
    
    for (NSDictionary *track in tracks) {
        [self scrobbleTrack:[track objectForKey:@"name"] byArtist:artist
                    onAlbum:album];
    }
}

@end
