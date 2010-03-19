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

void error_handler(int num, const char *m, const char *path);

int generic_handler(const char *path, const char *types, lo_arg **argv,
		    int argc, void *data, void *user_data);

int head_handler(const char *path, const char *types, lo_arg **argv, int argc,
		 void *data, void *user_data);


int receivedHeadAngle = 0;
VCAppController *sharedController = nil;

@implementation VCAppController

- (void)awakeFromNib
{
    sharedController = self;
    
    // initialize OSC sending to localhost:7000
    oscPd = lo_address_new(NULL, "7000");
    lo_send(oscPd, "/hello", ""); // make the connection
    
    // initialize OSC server on 7001
    st = lo_server_thread_new("7001", error_handler);
    lo_server_thread_add_method(st, NULL, NULL, generic_handler, NULL);
    lo_server_thread_add_method(st, "/vcon/head", "i", head_handler, NULL);
    lo_server_thread_start(st);
    
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

- (void)getHeadAngle
{
    [self handleHeadAngle:receivedHeadAngle];
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

- (IBAction)startStop:(id)sender
{
    if (!isStarted) {
        // send start message
        lo_send(oscPd, "/vcon/start", "");
        [spinner startAnimation:self];
        [startStopButton setTitle:@"Stop"];
        isStarted = YES;
        // wait 2 sec and stop the spinner
        NSInvocation *spinnerStop = [NSInvocation invocationWithMethodSignature:[spinner methodSignatureForSelector:@selector(stopAnimation:)]];
        [spinnerStop setTarget:spinner];
        [spinnerStop setSelector:@selector(stopAnimation:)];
        [spinnerStop setArgument:self atIndex:2];
        [NSTimer scheduledTimerWithTimeInterval:2 invocation:spinnerStop repeats:NO];
    } else {
        lo_send(oscPd, "/vcon/stop", "");
        [startStopButton setTitle:@"Start"];
        isStarted = NO;
    }

}

- (IBAction)doOrientation:(id)sender
{
    NSLog(@"doOrientation");
    orientation += 5;
    [self updateInstrumentPositions];
}

@end

#pragma mark OSC Handler Functions

void error_handler(int num, const char *msg, const char *path)
{
    printf("liblo server error %d in path %s: %s\n", num, path, msg);
    fflush(stdout);
}

/* catch any incoming messages and display them. returning 1 means that the
 * message has not been fully handled and the server should try other methods */
int generic_handler(const char *path, const char *types, lo_arg **argv,
		    int argc, void *data, void *user_data)
{
    int i;

    printf("path: <%s>\n", path);
    for (i=0; i<argc; i++) {
        printf("arg %d '%c' ", i, types[i]);
        lo_arg_pp(types[i], argv[i]);
        printf("\n");
    }
    printf("\n");
    fflush(stdout);

    return 1;
}

int head_handler(const char *path, const char *types, lo_arg **argv, int argc,
		 void *data, void *user_data)
{
    printf("%s <- i:%d\n\n", path, argv[0]->i);
    fflush(stdout);
    
    receivedHeadAngle = argv[0]->i;
    [sharedController performSelectorOnMainThread:@selector(getHeadAngle) withObject:nil waitUntilDone:NO];

    return 0;
}



