//
//  MyApp.m
//  NXMines
//
//  Created by G÷bor Sebesty›n on 2005.03.26..
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MyApp.h"

@implementation MyApp

- (void)finishLaunching
{
	[super finishLaunching];
    [gameWindow makeKeyAndOrderFront: self];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [gameWindow setDelegate: nil];
    [self terminate: self];
}

-(void) terminate:(id) sender
{
    [mineView saveScores];
	[super terminate: sender];
}

@end
