//
//  FMCallback.m
//  FMEngine
//
//  Created by Nicolas Haunold on 5/2/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import "FMCallback.h"

@implementation FMCallback

@synthesize target;
@synthesize selector;
@synthesize userInfo;
@synthesize identifier;

+ (id)callbackWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo {
	return [[FMCallback alloc] initWithTarget:target action:action userInfo:userInfo]; 
}

+ (id)callbackWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo object:(id)identifier {
	return [[FMCallback alloc] initWithTarget:target action:action userInfo:userInfo object:identifier]; 
}

- (id)initWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo {
	self = [super init];
	if (self) {
		self.target = target;
		self.selector = action;
		self.userInfo = userInfo;
	}
	
	return self;
}

- (id)initWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo object:(id)identifier {
	self = [super init];
	if(self) {
		self.target = target;
		self.selector = action;
		self.userInfo = userInfo;
		self.identifier = identifier;
	}
	
	return self;
}

- (void)fire {
	if(self.identifier == nil) {
		[self.target performSelector:self.selector withObject:self.userInfo];
	} else {
		[self.target performSelector:self.selector withObject:self.identifier withObject:self.userInfo];
	}
}

- (void)dealloc {
	// [super dealloc];
}


@end
