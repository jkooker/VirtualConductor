//
//  VCMainView.h
//  VirtualConductor
//
//  Created by John Kooker on 3/7/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VCAppController.h"

@interface VCMainView : NSView {
    IBOutlet VCAppController *appController;
    
    NSGradient *backgroundGradient;
}

- (IBAction)fullScreen:(id)sender;

@end
