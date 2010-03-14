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
    
    instrumentOffsets[0] = 0;
    instrumentOffsets[1] = 90;
    instrumentOffsets[2] = 180;
    instrumentOffsets[3] = 270;
    
    activeInstrumentIndex = 0;
}

- (void)handleGesture:(NSInteger)gestureID
{
    NSLog(@"handleGesture %d", gestureID);
    
    switch (gestureID) {
        case VCGestureVolumeUp:
            // check if it's maxed
            if (volumes[activeInstrumentIndex] < 100) {
                volumes[activeInstrumentIndex] += 20;
                [[instrumentViews objectAtIndex:activeInstrumentIndex] setInstrumentLevel:volumes[activeInstrumentIndex]];
            }
            break;
        case VCGestureVolumeDown:
            // check if it's already muted
            if (volumes[activeInstrumentIndex] > 0) {
                volumes[activeInstrumentIndex] -= 20;
                [[instrumentViews objectAtIndex:activeInstrumentIndex] setInstrumentLevel:volumes[activeInstrumentIndex]];
            }
            break;
        case VCGestureMute:
            if (volumes[activeInstrumentIndex] != 0) {
                volumes[activeInstrumentIndex] = 0;
                [[instrumentViews objectAtIndex:activeInstrumentIndex] setInstrumentLevel:volumes[activeInstrumentIndex]];
            }
            break;
        case VCGestureSolo:
        default:
            break;
    }
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

- (void)setActiveInstrumentIndex:(NSUInteger)i
{
    [[instrumentViews objectAtIndex:activeInstrumentIndex] setActive:NO];
    activeInstrumentIndex = i;
    [[instrumentViews objectAtIndex:activeInstrumentIndex] setActive:YES];
}

- (void)sendUpdatesToPd
{
    lo_send(oscPd, "/vcon/orientation", "i", orientation);
    lo_send(oscPd, "/vcon/volume", "if", 1, volumes[0]);
    lo_send(oscPd, "/vcon/volume", "if", 2, volumes[1]);
    lo_send(oscPd, "/vcon/volume", "if", 3, volumes[2]);
    lo_send(oscPd, "/vcon/volume", "if", 4, volumes[3]);
}

- (void)updateInstrumentPositions
{
    // do main frame calculations
    CGFloat center = [[guitarView superview] bounds].size.width / 2;
    
    for (NSUInteger i = 0; i < kInstrumentCount; i++) {
        VCInstrumentView *iView = [instrumentViews objectAtIndex:i];

        // calculate offset position
        CGFloat position = (orientation + instrumentOffsets[i]) % 360;
        if (position > 180) position -= 360; // now [-180, 180]
        
        // check if active instrument needs to be changed
        if (position > -45 && position <= 45) [self setActiveInstrumentIndex:i];
        
        CGFloat newFrameCenter = center + (position/45) * center;
        
        CGFloat halfInstrumentViewWidth = [iView bounds].size.width / 2;
        [iView setFrameOrigin:NSMakePoint(newFrameCenter - halfInstrumentViewWidth, [iView frame].origin.y)];
    }
}

- (IBAction)doOrientation:(id)sender
{
    orientation += 5;
    [self updateInstrumentPositions];
}

@end
