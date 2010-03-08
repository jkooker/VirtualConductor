//
//  VCMainView.m
//  VirtualConductor
//
//  Created by John Kooker on 3/7/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import "VCMainView.h"


@implementation VCMainView

- (void)awakeFromNib
{
    [self.window makeFirstResponder:self];
}

- (IBAction)fullScreen:(id)sender
{    
    if (![self isInFullScreenMode]) {
        // go full screen, as a kiosk application 
        [self enterFullScreenMode:[self.window screen] withOptions:nil];
        
        // Make the window the first responder to get keystrokes
        [self.window makeFirstResponder:self];
            
        // bring the window to the front
        [self.window makeKeyAndOrderFront:self];
    } else {
        [self exitFullScreenModeWithOptions:nil];
        [self.window makeFirstResponder:self];
    }

}

- (void)keyUp:(NSEvent *)theEvent
{
    NSLog(@"keyUp!");
    
    [super keyUp:theEvent];
}

@end
