//
//  SCRTabBarController.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/13/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import "SCRTabBarController.h"

@interface SCRTabBarController ()

@end

@implementation SCRTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"]
                    highlightImage:[UIImage imageNamed:@"cameraTabBarItemHighlight.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) willAppearIn:(UINavigationController *)navigationController
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"]
                    highlightImage:[UIImage imageNamed:@"cameraTabBarItemHighlight.png"]];
}

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    return self;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage
                  highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
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
}

@end
