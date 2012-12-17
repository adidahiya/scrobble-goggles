//
//  SCRCameraViewDelegate.h
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/16/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCRCameraViewController.h"

@interface SCRCameraViewDelegate : NSObject <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

- (void) initWithResultsViewController:(SCRCameraViewController *)controller;

@end
