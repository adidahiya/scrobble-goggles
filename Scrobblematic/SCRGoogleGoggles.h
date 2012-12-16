//
//  SCRGoogleGoggles.h
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/15/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCRGoogleGoggles : NSObject

- (long int) getCSSID;

- (void) validateCSSID:(NSString *) cssid;

@end
