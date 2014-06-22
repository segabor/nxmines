//
//  NXMineView.h
//  NXMines
//
//  Created by G÷bor Sebesty›n on 2005.03.26..
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


@interface NXMineView : NSView
{
    IBOutlet NSTextField	*bombDisplay;
    IBOutlet NSButton       *startButton;
    IBOutlet NSTextField	*timeDisplay;
    IBOutlet NSPanel        *scorePanel;
    IBOutlet NSTextField    *name0;
    IBOutlet NSTextField    *name1;
    IBOutlet NSTextField    *name2;
    IBOutlet NSTextField    *time0;
    IBOutlet NSTextField    *time1;
    IBOutlet NSTextField    *time2;

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

-(IBAction) setBeginner:sender;
-(IBAction) setMedium:sender;
-(IBAction) setExpert:sender;
-(id) setGameMode:(int)mode;
-(id) initFieldsW:(int)w H:(int)h Bombs:(int)Bombs;
-(IBAction) startGame:sender;
- endGame:(BOOL)win;

-(IBAction) buttonPushed: sender;
-(IBAction) rightButtonPushed: sender;

-(int) tagOfX:(int)x Y:(int)y;
-(void) checkAtX:(int)xx Y:(int)yy;
-(void) checkOneAtX:(int)xx Y:(int)yy;

-(IBAction) resetScores: sender;

-(void) loadScores;
-(void) saveScores;

/* text delegators */
- (void)textDidEndEditing:(NSNotification *)aNotification;
@end
