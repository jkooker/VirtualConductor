//
//  VCAppController.m
//  VirtualConductor
//
//  Created by John Kooker on 3/7/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import "VCAppController.h"

#define kMaxRotationalSpeed 180 // in degrees/sec
#define kTimerInterval 0.1 // in sec

@implementation VCAppController

- (void)awakeFromNib
{
    // initialize OSC sending to localhost:7000
    oscPd = lo_address_new(NULL, "7000");
    lo_send(oscPd, "/hello", ""); // make the connection
    
    // initialize state variables
    headAngle = 0;
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
    
    [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(updateWorld:) userInfo:nil repeats:YES];
}

- (void)handleGesture:(NSInteger)gestureID
{
    //NSLog(@"handleGesture %d", gestureID);
    
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
    //NSLog(@"handleHeadAngle %d", angle);
    
    // Update head angle indicator
    [headIndicator setIntValue:angle];
    headAngle = angle;
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
    lo_send(oscPd, "/vcon/volume", "ii", 1, volumes[0]);
    lo_send(oscPd, "/vcon/volume", "ii", 2, volumes[1]);
    lo_send(oscPd, "/vcon/volume", "ii", 3, volumes[2]);
    lo_send(oscPd, "/vcon/volume", "ii", 4, volumes[3]);
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

- (void)updateWorld:(NSTimer*)theTimer
{
    // update orientation based on head angle
    CGFloat orientationChange = ((CGFloat)headAngle / 45) * kTimerInterval * kMaxRotationalSpeed;
    orientation += orientationChange;
    orientation = orientation % 360;
    if (orientation < 0) orientation += 360;
    
    [self updateInstrumentPositions];
    [self sendUpdatesToPd];
}

- (IBAction)doOrientation:(id)sender
{
    orientation += 5;
    [self updateInstrumentPositions];
}

@end
