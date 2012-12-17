//
//  SCRGoogleGoggles.h
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/15/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCRCameraViewController.h"

@interface SCRGoogleGoggles : NSObject

- (NSString *) getCSSID;

- (void) validateCSSID:(NSString *)cssid;

- (void) queryWithImage:(UIImage *)photo
      toResultsDelegate:(SCRCameraViewController *)delegate;

@end
