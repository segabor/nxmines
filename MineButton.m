//
//  MineButton.m
//  NXMines
//
//  Created by Gábor Sebestyén on 2005.03.26..
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NXMineView.h"
#import "MineButton.h"


@implementation MineButton

-(id) initWithFrame:(NSRect)frameRect
{
	[super initWithFrame: frameRect];

	// set default behaviour
	[self setButtonType: NSMomentaryChangeButton];
	[self setImage: [NSImage imageNamed: @"brick.tiff"]];
	[self setAlternateImage: [NSImage imageNamed: @"brickPushed.tiff"]];
	[self setBordered: NO];
	
	return self;
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	if ([self target])
		[[self target] rightButtonPushed: self];
}

@end
