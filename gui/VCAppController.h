//
//  VCAppController.h
//  VirtualConductor
//
//  Created by John Kooker on 3/7/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "lo/lo.h"


@interface VCAppController : NSObject {
    lo_address oscPd;
}

- (void)handleGesture:(NSInteger)gestureID;
- (void)handleHeadOrientation:(NSInteger)angle;

@end
