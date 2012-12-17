//
//  SCRTabBarController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/13/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "SCRCameraViewDelegate.h"
#import "SCRTabBarController.h"

@interface SCRTabBarController ()

@property (nonatomic, strong) UIImagePickerController *camera;
@property (nonatomic, strong) SCRCameraViewDelegate *cameraDelegate;
@property (nonatomic, retain) IBOutlet UIButton *cameraButton;

@end

@implementation SCRTabBarController

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // NSLog(@"======================= ADDING CENTER BUTTON ======================");
    [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"]
                    highlightImage:[UIImage imageNamed:@"cameraTabBarItemHighlight.png"]];

    [self addButtonTapHandler:self.cameraButton];

    self.cameraDelegate = [[SCRCameraViewDelegate alloc] init];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willAppearIn:(UINavigationController *)navigationController
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"]
                    highlightImage:[UIImage imageNamed:@"cameraTabBarItemHighlight.png"]];
}

- (void) addButtonTapHandler:(UIButton *) button
{
    // NSLog(@"======================= ADDING TAP HANDLER ======================");
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleSingleFingerTap:)];

    [button addGestureRecognizer:singleFingerTap];
}

- (void) handleSingleFingerTap:(UITapGestureRecognizer *)recognizer
{
    // NSLog(@"=================== INSIDE SINGLE TAP HANDLER ===================");
    if ([self startCameraController] == YES) {
        NSLog(@"Camera UI started!");
    } else {
        NSLog(@"Camera failed to launch.");
    }
}

// Create a view controller and setup it's tab bar item with a title and image
- (UIViewController*) viewControllerWithTabTitle:(NSString*)title
                                           image:(UIImage*)image
{
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    return self;
}

// Create a custom UIButton and add it to the center of this tab bar
- (void) addCenterButtonWithImage:(UIImage*)buttonImage
                   highlightImage:(UIImage*)highlightImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
                            | UIViewAutoresizingFlexibleLeftMargin
                            | UIViewAutoresizingFlexibleBottomMargin
                            | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];

    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }

    [self.view addSubview:button];
    self.cameraButton = button;
}

// Capture a photo with the camera

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

    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
    
    // self.camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    // Only allow still images
    camera.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    camera.allowsEditing = NO;

    // Tell the camera delegate (UIImagePickerControllerDelegate) about the
    // results view controller (child controller of this tab bar)
    SCRAlbumResultsController *controller = (SCRAlbumResultsController *) [self.viewControllers objectAtIndex:1];
    [self.cameraDelegate initWithResultsViewController:controller];
    camera.delegate = self.cameraDelegate;

    [self presentViewController:camera animated:YES completion:NULL];
    
    self.camera = camera;
    return YES;
}

@end