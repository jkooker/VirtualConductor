//
//  VirtualConductorAppDelegate.h
//  VirtualConductor
//
//  Created by John Kooker on 2/23/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VirtualConductorAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
