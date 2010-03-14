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
    [self.window setAcceptsMouseMovedEvents:YES];
    
    backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.2 alpha:1.0]];
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

- (void)drawRect:(NSRect)rect {
    [backgroundGradient drawInRect:[self bounds] angle:270];
}

#pragma mark Event Handling

- (void)keyDown:(NSEvent *)theEvent
{
    // stop the beep on keypresses
}

- (void)keyUp:(NSEvent *)theEvent
{
    //NSLog(@"keyUp with characters %@!", [theEvent characters]);
    
    if ([[theEvent characters] isEqualToString:@"a"]) {
        [appController handleGesture:1];
    } else if ([[theEvent characters] isEqualToString:@"s"]) {
        [appController handleGesture:2];
    } else if ([[theEvent characters] isEqualToString:@"d"]) {
        [appController handleGesture:3];
    } else if ([[theEvent characters] isEqualToString:@"f"]) {
        [appController handleGesture:4];
    } else {
        [super keyUp:theEvent];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    //NSLog(@"mouseMoved to (%.0f, %.0f)!", [NSEvent mouseLocation].x, [NSEvent mouseLocation].y);
    
    CGFloat width = [[self.window screen] frame].size.width;
    CGFloat x = [NSEvent mouseLocation].x;
    
    // Left edge of screen is -45 degrees, right side is 45
    NSInteger angle = (x - width/2)/(width/2) * 45;
    
    [appController handleHeadAngle:angle];
    
    [super mouseMoved:theEvent];
}

@end
