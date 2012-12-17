//
//  UtilityFunctions.h
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/17/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityFunctions : NSObject

+ (void)saveToUserDefaults:(NSString*)key value:(NSString*)valueString;

+ (NSString*)retrieveFromUserDefaults:(NSString*)key;

@end
