//
//  SCRCameraViewController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/13/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "SCRCameraViewController.h"

@interface SCRCameraViewController ()

@property UIImagePickerController *camera;

@end

@implementation SCRCameraViewController // (CameraDelegateMethods)

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    if ([self startCameraController]) {
        NSLog(@"Camera UI started!");
    } else {
        NSLog(@"Camera failed to launch.");
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) startCameraController
{
    /*
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera] == NO)
        return NO;
     */
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        return NO;

    self.camera = [[UIImagePickerController alloc] init];
    // self.camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    // Only allow still images
    self.camera.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    self.camera.allowsEditing = NO;

    self.camera.delegate = self;

    [self presentViewController:self.camera animated:YES completion:NULL];
    return YES;
}

// UINavigationControllerDelegate methods ======================================

- (void) navigationController:(UINavigationController *)navigationController
        didShowViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
{

}

- (void) navigationController:(UINavigationController *)navigationController
       willShowViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
{

}

// UIImagePickerControllerDelegate methods =====================================

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [self.camera dismissViewControllerAnimated:YES completion:NULL];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];

    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {

        // Save the new image to the Camera Roll
        UIImageWriteToSavedPhotosAlbum ([info objectForKey:
                                         UIImagePickerControllerOriginalImage],
                                        nil, nil , nil);
    }

    [self.camera dismissViewControllerAnimated:YES completion:NULL];
}

@end
