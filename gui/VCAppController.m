//
//  VCAppController.m
//  VirtualConductor
//
//  Created by John Kooker on 3/7/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import "VCAppController.h"


@implementation VCAppController

- (void)awakeFromNib
{
    // initialize OSC sending to localhost:7000
    oscPd = lo_address_new(NULL, "7000");
    lo_send(oscPd, "/hello", ""); // make the connection
}

- (void)handleGesture:(NSInteger)gestureID
{
    NSLog(@"handleGesture %d", gestureID);
    
    // Fake gestures into volume controls
    float newVolume = ((float)gestureID - 1) / 3 * 100;
    lo_send(oscPd, "/volume", "if", 1, newVolume);
}

- (void)handleHeadOrientation:(NSInteger)angle
{
    NSLog(@"handleHeadOrientation %d", angle);
    
    // Need to implement constant motion, but this will do for now.
    lo_send(oscPd, "/orientation", "i", angle);
}

@end
