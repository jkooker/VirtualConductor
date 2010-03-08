//
//  VCAppController.m
//  VirtualConductor
//
//  Created by John Kooker on 3/7/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import "VCAppController.h"


@implementation VCAppController

- (void)handleGesture:(NSInteger)gestureID
{
    NSLog(@"handleGesture %d", gestureID);
}

- (void)handleHeadOrientation:(NSInteger)angle
{
    NSLog(@"handleHeadOrientation %d", angle);    
}

@end
