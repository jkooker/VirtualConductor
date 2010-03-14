//
//  VCInstrumentView.m
//  VirtualConductor
//
//  Created by John Kooker on 3/13/10.
//  Copyright 2010 John Kooker. All rights reserved.
//

#import "VCInstrumentView.h"


@implementation VCInstrumentView

/*
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}
*/

- (void)setInstrumentLevel:(NSInteger)newLevel
{
    // map [0,100] to [0,5]
    [level setIntValue:(newLevel / 20)];
}

@end
