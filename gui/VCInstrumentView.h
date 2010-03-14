//
//  VCInstrumentView.h
//  VirtualConductor
//
//  Created by John Kooker on 3/13/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VCInstrumentView : NSView {
    IBOutlet NSImageView *image;
    IBOutlet NSLevelIndicator *level;
    IBOutlet NSTextField *text;
    
    BOOL isActive;
}

- (void)setInstrumentLevel:(NSInteger)newLevel;
- (void)setActive:(BOOL)newActive;

@end
