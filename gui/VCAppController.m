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
    
    // initialize state variables
    orientation = 0;
    volumes[0] = 100;
    volumes[1] = 100;
    volumes[2] = 100;
    volumes[3] = 100;
    
    instrumentViews = [[NSArray alloc] initWithObjects:guitarView, voxView, drumsView, crowdView, nil];
}

- (void)handleGesture:(NSInteger)gestureID
{
    NSLog(@"handleGesture %d", gestureID);
    
    switch (gestureID) {
        case VCGestureVolumeUp:
            // check if it's maxed
            if (volumes[0] < 100) {
                volumes[0] += 20;
                [[instrumentViews objectAtIndex:0] setInstrumentLevel:volumes[0]];
            }
            break;
        case VCGestureVolumeDown:
            // check if it's already muted
            if (volumes[0] > 0) {
                volumes[0] -= 20;
                [[instrumentViews objectAtIndex:0] setInstrumentLevel:volumes[0]];
            }
            break;
        case VCGestureMute:
            if (volumes[0] != 0) {
                volumes[0] = 0;
                [[instrumentViews objectAtIndex:0] setInstrumentLevel:volumes[0]];
            }
            break;
        case VCGestureSolo:
        default:
            break;
    }
    /*
    if (gestureID == VCGestureVolumeUp) {
        // check if it's maxed
        if (volumes[0] != 100) {
            volumes[0] += 20;
            [[instrumentViews objectAtIndex:0] setLevel:volumes[0]];
        }
    }
    
    // Fake gestures into volume controls
    float newVolume = ((float)gestureID - 1) / 3 * 100;
    lo_send(oscPd, "/vcon/volume", "if", 1, newVolume);
    */
}

- (void)handleHeadAngle:(NSInteger)angle
{
    NSLog(@"handleHeadOrientation %d", angle);
    
    // Update orientation indicator
    [headIndicator setIntValue:angle];
    
    // Need to implement constant motion, but this will do for now.
    lo_send(oscPd, "/vcon/orientation", "i", angle);
    
    // Move instrument view with head orientation
    [guitarView setFrameOrigin:NSMakePoint([[guitarView superview] bounds].size.width / 2 + angle,
        [guitarView frame].origin.y)];
}

- (void)setOrientation:(NSInteger)angle
{
    orientation = angle;
}

- (void)sendUpdatesToPd
{
    lo_send(oscPd, "/vcon/orientation", "i", orientation);
    lo_send(oscPd, "/vcon/volume", "if", 1, volumes[0]);
    lo_send(oscPd, "/vcon/volume", "if", 2, volumes[1]);
    lo_send(oscPd, "/vcon/volume", "if", 3, volumes[2]);
    lo_send(oscPd, "/vcon/volume", "if", 4, volumes[3]);
}

@end
