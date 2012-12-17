//
//  SCRAppDelegate.h
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/13/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UtilityFunctions.h"
#import "SCRLastFM.h"

@interface SCRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SCRLastFM *lastFM;

- (void) initLastFM;

@end
