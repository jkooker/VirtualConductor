//
//  VCAppController.h
//  VirtualConductor
//
//  Created by John Kooker on 3/7/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VCAppController : NSObject {

}

- (void)handleGesture:(NSInteger)gestureID;
- (void)handleHeadOrientation:(NSInteger)angle;

@end
