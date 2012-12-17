//
//  SCRCameraViewDelegate.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/16/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>

#import "SCRCameraViewDelegate.h"

@interface SCRCameraViewDelegate ()

@property SCRGoogleGoggles *goggles;
@property SCRAlbumResultsController *resultsController;

@end

@implementation SCRCameraViewDelegate

- (void) initWithResultsViewController:(SCRAlbumResultsController *)controller
{
    self.resultsController = controller;
    self.goggles = [[SCRGoogleGoggles alloc] init];
}

// UINavigationControllerDelegate methods ======================================

- (void) navigationController:(UINavigationController *)navigationController
        didShowViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
{
    // NSLog(@"didShowViewController");
}

- (void) navigationController:(UINavigationController *)navigationController
       willShowViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
{
    // NSLog(@"willShowViewController");
}

@end

// UIImagePickerControllerDelegate methods =====================================

@implementation SCRCameraViewDelegate (CameraDelegateMethods)

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // NSLog(@"*********** imagePickerControllerDidCancel **********");
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // NSLog(@"*********** didFinishPickingMediaWithInfo **********");

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *image;

    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {

        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // Save the new image to the Camera Roll
        // UIImageWriteToSavedPhotosAlbum (image, nil, nil , nil);

        [self.goggles queryWithImage:image
                   toResultsDelegate:self.resultsController];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
