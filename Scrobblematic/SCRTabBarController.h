//
//  SCRTabBarController.h
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/13/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRTabBarController : UITabBarController {
    
}

// Create a view controller and setup its tab bar item with a title and image
- (UIViewController *) viewControllerWithTabTitle:(NSString *)title
                                            image:(UIImage *)image;

// Create a custom UIButton and add it to the center of our tab bar
- (void) addCenterButtonWithImage:(UIImage *)buttonImage
                   highlightImage:(UIImage *)highlightImage;

@end
