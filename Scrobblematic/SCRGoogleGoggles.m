//
//  SCRGoogleGoggles.m
//  Scrobblematic
//
//  Created by Adi Dahiya on 12/15/2012.
//  Copyright (c) 2012 Adi Dahiya. All rights reserved.
//
// Mostly derived from http://notanothercodeblog.blogspot.com/2011/02/google-goggles-api.html
//

#include <stdlib.h>
#include <UIKit/UIImage.h>

#import "SCRCameraViewController.h"
#import "SCRAppDelegate.h"
#import "SCRGoogleGoggles.h"

@interface SCRGoogleGoggles ()

@property NSString *CSSID;   // String of 16 random hexadecimal values
@property UIImage *image;   // Image to query Goggles API with
@property SCRCameraViewController *resultsViewController;

@end


@implementation SCRGoogleGoggles

NSString *GOGGLES_API_URL_FORMAT = @"http://www.google.com/goggles/container_proto?cssid=%@";
NSString *MOBILE_USER_AGENT = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_1_3 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7E18 Safari/528.16 GoogleMobileApp/0.7.3.5675 GoogleGoggles-iPhone/1.0; gzip";

char CSSID_BYTE_ARRAY[64] = {
    0x22, 0x00, 0x62, 0x3C, 0x0A, 0x13, 0x22, 0x02,
    0x65, 0x6E, 0xBA, 0xD3, 0xF0, 0x3B, 0x0A, 0x08,
    0x01, 0x10, 0x01, 0x28, 0x01, 0x30, 0x00, 0x38,
    0x01, 0x12, 0x1D, 0x0A, 0x09, 0x69, 0x50, 0x68,
    0x6F, 0x6E, 0x65, 0x20, 0x4F, 0x53, 0x12, 0x03,
    0x34, 0x2E, 0x31, 0x1A, 0x00, 0x22, 0x09, 0x69,
    0x50, 0x68, 0x6F, 0x6E, 0x65, 0x33, 0x47, 0x53,
    0x1A, 0x02, 0x08, 0x02, 0x22, 0x02, 0x08, 0x01
};

char IMAGE_POST_TRAILING_BYTES[22] = {
    0x18, 0x4B, 0x20, 0x01, 0x30, 0x00, 0x92, 0xEC,
    0xF4, 0x3B, 0x09, 0x18, 0x00, 0x38, 0xC6, 0x97,
    0xDC, 0xDF, 0xF7, 0x25, 0x22, 0x00
};

NSURLConnection *_cssidPOST;
NSURLConnection *_imagePOST;
NSMutableData *_resultsData;


// External API method to initialize Google Goggles API interaction
- (void) queryWithImage:(UIImage *)photo
      toResultsDelegate:(SCRCameraViewController *)delegate
{
    self.image = photo;
    self.resultsViewController = delegate;
    [self validateCSSID:[self getCSSID]];
}

/*
 * Set the necessary parameters for a request to the Google Goggles API, which
 * uses proto buffers as its data exchange format.
 */
- (NSMutableURLRequest *) generateGogglesRequest:(NSString *)cssid
{
    NSString *url = [NSString stringWithFormat:GOGGLES_API_URL_FORMAT, cssid];
    // NSLog(@"Goggles API request url: [%@]", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    
    // Specific to Google Goggles API
    [request setValue:@"application/x-protobuffer" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [request setValue:MOBILE_USER_AGENT forHTTPHeaderField:@"UserAgent"];
    return request;
}

/*
 * http://stackoverflow.com/questions/7622887/generating-a-random-32-bit-hexadecimal-value-in-c
 */
- (long int) generateRandomLong
{
    int range = pow(2, 8);
    unsigned short r1 = arc4random_uniform(range);
    unsigned short r2 = arc4random_uniform(range);
    unsigned short r3 = arc4random_uniform(range);
    unsigned short r4 = arc4random_uniform(range);
    
    return (r1 & 0xff)
         | (r2 & 0xff) << 8
         | (r3 & 0xff) << 16
         | (r4 & 0xff) << 24;
}

/*
 * If a valid CSSID exists, return it. Otherwise, generate a sequence of 16
 * random hexadecimal values
 */
- (NSString *) getCSSID
{
    if (self.CSSID == nil) {
        // Generate a new CSSID
        long int hex1 = [self generateRandomLong];
        long int hex2 = [self generateRandomLong];
        
        self.CSSID = [NSString stringWithFormat:@"%08lX%08lX", hex1, hex2];
    }
    
    return self.CSSID;
}

/*
 * Attempt to validate the given CSSID. If it fails, generate a new one and keep
 * trying.
 */
- (void) validateCSSID:(NSString *)cssid
{
    NSMutableURLRequest *request = [self generateGogglesRequest:cssid];
    [request setHTTPBody:[NSData dataWithBytes:CSSID_BYTE_ARRAY length:64]];

    _cssidPOST = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_cssidPOST start];
}

// Handle async POST response ==================================================

- (void) connection:(NSURLConnection *)connection
 didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    bool isOK = [httpResponse statusCode] == 200;

    if (connection == _cssidPOST) {
        // Handle validateCSSID response
        if (isOK) {
            // [self.resultsDelegate showResults:results];
            [self postImage:self.image];
        } else {
            // If not 200 OK, then attempt to validate a new CSSID
            NSLog(@"validateCSSID POST connection returned %d status code", [httpResponse statusCode]);
            self.CSSID = nil;
            [self validateCSSID:[self getCSSID]];
        }
    } else if (connection == _imagePOST) {
        // TODO: Handle postImage response
        _resultsData = [[NSMutableData alloc] init];

        if (isOK) {
            NSLog(@"Image POST connection got 200 OK");
        } else {
            NSLog(@"Image POST connection returned %d status code", [httpResponse statusCode]);
            NSLog(@"response header: %@", [httpResponse allHeaderFields]);
        }
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _imagePOST && _resultsData != nil && data != nil) {
        [_resultsData appendData:data];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _imagePOST) {
        NSArray *data = [NSJSONSerialization JSONObjectWithData:_resultsData
                                                        options:0 error:nil];
        // NSLog(@"Got data array in image POST response: %@", data);

        // Present the results view controller from the application's root view
        // controller
        SCRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        UITabBarController *tabBarController = (UITabBarController *) appDelegate.window.rootViewController;

        int resultsLength = [_resultsData length];
        char dataStringBuffer[resultsLength];
        [_resultsData getBytes:dataStringBuffer length:resultsLength];

        NSString *dataString = [NSString stringWithFormat:@"%s", dataStringBuffer];

        NSLog(@"Got data of length %i: %@", resultsLength, dataString);

        // Switch to results view tab
        tabBarController.selectedIndex = 1;
        SCRCameraViewController *resultsView = [tabBarController.viewControllers
                                                objectAtIndex:1];
        [resultsView showResults:dataString];
    }

    [connection cancel];
}

- (void) connection:(NSURLConnection *)connection
   didFailWithError:(NSError *)error
{
    // TODO: handle failure
    NSLog(@"connection failed with: %@", error);
}

// =============================================================================

/*
 * Encode a number into a varint using the following algorithm:
 * 
 * 1. Convert the number into binary:
 *      110110101010001
 *
 * 2. From right to left, divide the bits into groups of 7 bits each. Append
 *    zeros to the most left group to make it 7 bits if needed:
 *      0000001 1011010 1010001
 *
 * 3. Reverse the groups:
 *      1010001 1011010 0000001
 *
 * 4. Convert the groups of 7 bits into bytes. From left to right, set the msb
 *    (most significant bit) if there are further bytes to come. If you reach
 *    the last byte, the msb should 0:
 *      11010001 11011010 00000001
 *      0xD1DA01
 *
 * 5. Conver the result into a byte array and prepend it with 0x0A
 */
- (NSData *) encodeVarint:(int)value
{
    char SEVEN_BIT_MASK = 0x7f;
    char MSB_MASK = 0x80;
    
    char p1 = (value >> 14) & SEVEN_BIT_MASK;
    char p2 = ((value >> 7) & SEVEN_BIT_MASK) | MSB_MASK;
    char p3 = (value & SEVEN_BIT_MASK) | MSB_MASK;

    // Reverse order of 7-bit groups (each is padded with a MSB to make a byte)
    char bytes[4] = { 0x0A, p3, p2 & 0xff, p1 };

    return [[NSData alloc] initWithBytes:bytes length:4];
}

/*
 * Set up the image data and query the Google Goggles API.
 *
 * http://stackoverflow.com/questions/6385324/size-of-uiimgae-in-bytes-in-ios-4-0
 */
- (void) postImage:(UIImage *)image
{
    NSMutableURLRequest *request = [self generateGogglesRequest:[self getCSSID]];

    // IMPORTANT: compression factor here
    // Under 140KB images seem to be working
    NSData *imageData = [[NSData alloc]
                         initWithData:UIImageJPEGRepresentation(self.image, 0.5)];
    int imageSize = imageData.length;
    NSLog(@"imageSize: (%i)", imageData.length);

    // encodeVarint returns a fully encoded 4-byte array wrapped in NSData
    NSData *a = [self encodeVarint:(imageSize + 32)];
    NSData *b = [self encodeVarint:(imageSize + 14)];
    NSData *c = [self encodeVarint:(imageSize + 10)];
    NSData *x = [self encodeVarint:(imageSize)];

    NSMutableData *byteArray = [[NSMutableData alloc] init];
    [byteArray appendData:a];
    [byteArray appendData:b];
    [byteArray appendData:c];
    [byteArray appendData:x];
    [byteArray appendData:imageData];
    [byteArray appendBytes:IMAGE_POST_TRAILING_BYTES length:22];

    [request setHTTPBody:byteArray];

    NSLog(@"******************** init imagePOST request ********************");
    _imagePOST = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

@end