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

#define BEGINNER 0
#define MEDIUM 1
#define EXPERT 2

#define CHECKED	0x04
#define FLAG	0x08
#define INVALID	0x10

#define INTERVAL 1
#define PRIORITY 1

// void timer(DPSTimedEntry tEntry, double now, void *udata);

@interface NXMineView : NSView
{
    id	bombDisplay;
    id	startButton;
    id	timeDisplay;
    id	scorePanel;
    id	name0;
    id	name1;
    id	name2;
    id	time0;
    id	time1;
    id	time2;

	NSMutableArray	*fieldsList;
	int gameMode;
	BOOL isRunning;
	BOOL timerOn;
	NSTimer	*timer;
	int bombs;
	int flagsInBomb;
	int fw, fh, fc;
	int maxspc;
	int temp;
	
	id actTextField;
	
	BOOL showAll;
}

// - postInit: sender;
-(void) tick: (NSTimer *) aTimer;
- (BOOL)acceptsFirstResponder;

- setBeginner:sender;
- setMedium:sender;
- setExpert:sender;
- setGameMode:(int)mode;
- initFieldsW:(int)w H:(int)h Bombs:(int)Bombs;
- startGame:sender;
- endGame:(BOOL)win;

-(void) buttonPushed: sender;
-(void) rightButtonPushed: sender;

-(int) tagOfX:(int)x Y:(int)y;
-(void) checkAtX:(int)xx Y:(int)yy;
-(void) checkOneAtX:(int)xx Y:(int)yy;

-(void) resetScores: sender;

-(void) loadScores;
-(void) saveScores;

/* text delegators */
- (void)textDidEndEditing:(NSNotification *)aNotification;
@end
