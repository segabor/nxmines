//
//  MineButton.m
//  NXMines
//
//  Created by Gábor Sebestyén on 2005.03.26..
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#ifdef _NEXT_SOURCE
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import "NXMineView.h"

@interface MyApp : NSApplication
{
    id	gameWindow;
    id	mineView;
}

@end
