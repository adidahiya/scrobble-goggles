//
//  SCRLastFM.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/17/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//
//  Uses FMEngine: https://github.com/westbaer/FMEngine
//

#import "SCRLastFM.h"

@interface SCRLastFM ()

@property NSString *sessionKey;
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
	NSString *authToken = [fmEngine generateAuthTokenFromUsername:username
                                                         password:password];
	NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             username, @"username",
                             authToken, @"authToken",
                             _LASTFM_API_KEY_, @"api_key",
                             nil, nil];

	[fmEngine performMethod:@"auth.getMobileSession" withTarget:self
             withParameters:urlDict andAction:@selector(loginCallback:data:)
               useSignature:YES httpMethod:POST_TYPE];
}

- (void) loginCallback:(NSString *)identifier data:(id)data {
	// data is either NSData or NSError
	NSLog(@"Got Data (%@): %@", identifier, data);
    // NSLog(@"Last.fm auth token: %@", data);
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0
                                                           error:nil];
    self.sessionKey = [[json objectForKey:@"session"] objectForKey:@"key"];
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

    int totalResults = [[[json objectForKey:@"results"]
                        objectForKey:@"opensearch:totalResults"] intValue];
    NSLog(@"Got %d album match(es) for %@", totalResults, album);

    if (totalResults) {
        NSArray *matches = [[[json objectForKey:@"results"]
                             objectForKey:@"albummatches"]
                            objectForKey:@"album"];

        // Without this, NSDictionary would be interpreted as NSArray
        if (totalResults == 1) {
            matches = [NSArray arrayWithObjects:matches, nil];
        }

        return matches;
    } else {
        // Attempt to split on dash within album name (in artist - album format)
        // If no split possible, return an empty NSArray
        NSString *pattern = @"([\\w\\s\\!]+)\\-([\\w\\s\\!]+)";
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:pattern
                                      options:NSRegularExpressionSearch error:nil];
        NSArray *matches = [regex matchesInString:album
                                          options:NSRegularExpressionSearch
                                            range:NSMakeRange(0, [album length])];
        NSArray *ret;

        for (NSTextCheckingResult *match in matches) {
            NSString *substr = [album substringWithRange:[match rangeAtIndex:1]];
            ret = [self getAlbumMatches:substr];
            if ([ret count]) return ret;
        }

        return [[NSArray alloc] init];
    }
}

- (NSArray *) getRecentScrobbles
{
    NSDictionary *getRecentParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     _LASTFM_API_KEY_, @"api_key",
                                     @"20", @"limit",
                                     self.username, @"user",
                                     nil, nil];
    NSData *data = [fmEngine dataForMethod:@"user.getRecentTracks"
                            withParameters:getRecentParams useSignature:YES
                                httpMethod:POST_TYPE error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0
                                                           error:nil];
    NSArray *recent = [[json objectForKey:@"recenttracks"] objectForKey:@"track"];
    return recent;
}

- (void) scrobbleTrack:(NSString *)track byArtist:(NSString *)artist
               onAlbum:(NSString *)album
{
    assert(self.sessionKey != nil);

    long time = (long) [[NSDate date] timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%ld", time];

    NSDictionary *scrobbleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    _LASTFM_API_KEY_, @"api_key",
                                    artist, @"artist",
                                    track, @"track",
                                    album, @"album",
                                    timestamp, @"timestamp",
                                    self.sessionKey, @"sk",
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
