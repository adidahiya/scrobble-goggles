//
//  SCRCameraViewDelegate.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/16/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "SCRCameraViewDelegate.h"
#import "SCRGoogleGoggles.h"

@interface SCRCameraViewDelegate ()

@property SCRGoogleGoggles *goggles;

@end

@implementation SCRCameraViewDelegate

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end

// UIImagePickerControllerDelegate methods =====================================

@implementation SCRCameraViewDelegate (CameraDelegateMethods)

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        // Save the new image to the Camera Roll
        UIImageWriteToSavedPhotosAlbum ([info objectForKey:
                                         UIImagePickerControllerOriginalImage],
                                        nil, nil , nil);
        // TODO: goggles stuff
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
