//
//  SCRLastFM.h
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/17/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMEngine.h"

@interface SCRLastFM : NSObject {
    FMEngine *fmEngine;
}

- (void) initUser:(NSString *)username withPassword:(NSString *)password;

- (NSArray *) getAlbumMatches:(NSString *)album;

- (void) scrobbleAlbum:(NSString *)album byArtist:(NSString *)artist;

@end
