//
//  SCRGoogleGoggles.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/15/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//

#include <stdlib.h>
#import "SCRGoogleGoggles.h"

@interface SCRGoogleGoggles ()

@property long int CSSID;

@end

@implementation SCRGoogleGoggles

- (long int) getCSSID
{
    if (self.CSSID) {
        return self.CSSID;
    } else {
        // I am not familiar enough with objective C to do this in a better way,
        // definitely some optimization to be done here
        
        // http://stackoverflow.com/questions/7622887/generating-a-random-32-bit-hexadecimal-value-in-c
        
        long int hex = rand() & 0xff;
        hex |= (rand() & 0xff) << 8;
        hex |= (rand() & 0xff) << 16;
        hex |= (rand() & 0xff) << 24;
        
        return hex;
        /*
        unsigned short rand = arc4random_uniform(100);
        NSLog(@"%hX", rand);
        NSString *cssid = [NSString stringWithFormat:@"%hX", rand];

        // TODO: make this string length 16
        return cssid;
        */
    }
}

- (void) validateCSSID:(NSString *) cssid
{
    NSString *url = [NSString stringWithFormat:@"http://www.google.com/goggles/container_proto?cssid=%lX", self.getCSSID];
    NSLog(@"url: [%@]", url);
    /*
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];

    [request setHTTPMethod:@"POST"];

    // TODO: send POST request
    NSString *data = nil;
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
    [connection start];
     */
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    // TODO: handle response from POST
}

@end
