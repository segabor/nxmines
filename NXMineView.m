
#import "MineButton.h"
#import "NXMineView.h"

int dx[] = {-1,  0,  1, -1, 1, -1, 0, 1};
int dy[] = {-1, -1, -1,  0, 0,  1, 1, 1};

const NSString *iNumbers[] = {
	@"brickPushed.tiff",
	@"brick1.tiff",
	@"brick2.tiff",
	@"brick3.tiff",
	@"brick4.tiff",
	@"brick5.tiff",
	@"brick6.tiff",
	@"brick7.tiff",
	@"brick8.tiff"
};

@implementation NXMineView

- (void)awakeFromNib
{
    gameMode = BEGINNER;
    isRunning = NO;
    fieldsList = [[NSMutableArray array] retain];

	isRunning = NO;
	timerOn = NO;
	timer = nil;
	showAll = NO;
	actTextField = nil;

	[self loadScores];
	
    [name0 setDelegate: self];
    [name1 setDelegate: self];
    [name2 setDelegate: self];

    [self setGameMode: gameMode];
}

-(void) dealloc
{
	if (fieldsList)
		[fieldsList autorelease];
	
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	
	[super dealloc];
}


-(void) tick: (NSTimer *) aTimer
{
	temp++;
	[timeDisplay setIntValue: temp];
	if (temp > 999) {
		[timer invalidate];
		timer = nil;
		timerOn = NO;
	}
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- initFieldsW:(int)w H:(int)h Bombs:(int)Bombs
{
    int i, g;
    NSButton *obj;
    NSRect aRect;

    [[self window] setAutodisplay: NO];

    bombs = Bombs;
	flagsInBomb = 0;

    fw = w;
    fh = h;
    fc = w*h;

    //[[self window] sizeWindow: 16 + (fw*18) : 16 + 64 + (fh*18)];
	aRect = [[self window] frame];
	aRect.size.width = 16 + (fw*18);
	aRect.size.height = 16 + 64 + (fh*18);
	[[self window] setFrame: aRect display: YES];
	
    aRect = [self frame];
    aRect.size.width = (fw*18);
    aRect.size.height = (fh*18);
    [self setFrame: aRect];

    [[self window] display];

    for (i=0; i<h ; i++) {
		for (g=0; g<w; g++) {
			// obj = [[NSButton alloc] initWithFrame: NSMakeRect((g*18), (i*18), 18, 18)];
			obj = [[MineButton alloc] initWithFrame: NSMakeRect((g*18), (i*18), 18, 18)];

			/*
			[obj setButtonType: NSMomentaryChangeButton];
			[obj setImage: [NSImage imageNamed: @"brick.tiff"]];
			[obj setAlternateImage: [NSImage imageNamed: @"brickPushed.tiff"]];
			[obj setBordered: NO];
			 */
			[obj setTarget: self];
			[obj setAction:@selector(buttonPushed:)];

			[self addSubview: obj];

			[fieldsList addObject: obj];
		}
    }


    [[self window] setAutodisplay: YES];
    return self;
}

- setBeginner: sender
{
    [self setGameMode:BEGINNER];
    return self;
}

- setMedium: sender
{
    [self setGameMode:MEDIUM];
    return self;
}

- setExpert: sender
{
    [self setGameMode:EXPERT];
    return self;
}

- setGameMode:(int)mode
{
    int i;
	
    if (isRunning == YES) {
		isRunning = NO;
    }
	
    if ([fieldsList count]>0) {
		for (i=0; i<[fieldsList count]; i++) {
			[[fieldsList objectAtIndex: i] removeFromSuperview];			
		}
		[fieldsList removeAllObjects];
	}
	
	gameMode = mode;
	
	switch (gameMode) {
		case BEGINNER:
			[self initFieldsW:10 H:10 Bombs: 10];
			[[self window] setTitle: @"NXMines - Beginner"];
			break;
		case MEDIUM:
			[self initFieldsW:20 H:20 Bombs: 60];
			[[self window] setTitle: @"NXMines - Medium"];
			break;
		case EXPERT:
			[self initFieldsW:20 H:20 Bombs: 100];
			[[self window] setTitle: @"NXMines - Expert"];
			break;
		default: 
			[self initFieldsW:10 H:10 Bombs: 10];
			[[self window] setTitle: @"NXMines - Beginner"];
			break;
	}
	
	[self startGame: self];
	NSBeep();
    return self;
}

- startGame:sender
{
    int i;
    int rnd;
    id obj;

    [[self window] setAutodisplay: NO];

    if (timerOn == YES) {
		[timer invalidate];
		timer = nil;
		
		timerOn = NO;
    }

    for (i=0; i<[fieldsList count]; i++) {
		obj = [fieldsList objectAtIndex: i];
		[obj setTag: 0];
		[obj setEnabled: YES];
		[obj setImage: [NSImage imageNamed: @"brick.tiff"]];
	}

    for (i=0; i<bombs; i++) {
		do {
			rnd = (int)(random() % fc);
		} while ([[fieldsList objectAtIndex: rnd] tag] == 1);
		
		[[fieldsList objectAtIndex: rnd] setTag: 1];
    }

    [[self window] setAutodisplay: YES];
    isRunning = YES;

    [bombDisplay setIntValue: bombs];
    [timeDisplay setIntValue: 0];
    
	// [scorePanel orderFront: self];

    actTextField = nil;
    temp = 0;

    [self display];

    maxspc = fc;
    return self;
}

- endGame:(BOOL)win
{
    id tm, nm;

    isRunning = NO;
    if (timerOn == YES) {
		[timer invalidate];
		timer = nil;

		timerOn = NO;
	}

    if (win == YES) {
		switch (gameMode) {
			case BEGINNER:
				tm = time0;
				nm = name0;
				break; 
			case MEDIUM:
				tm = time1;
				nm = name1;
				break;
			case EXPERT:
				tm = time2;
				nm = name2;
				break;
		}	
		if (temp <= [tm intValue]) {
			NSRunAlertPanel(@"You Won!!", @"... and you made best time!", @"OK", nil, nil);
			[tm setIntValue: temp];
			[nm setEditable: YES];
			//	    [nm selectAll: self];
			[scorePanel makeKeyAndOrderFront: self];
			actTextField = nm;	    
		} else
			NSRunAlertPanel(@"You Won!", @"Wow, you made it!", @"OK", nil, nil);
    } else
	NSRunAlertPanel(@"You Blasted!", @"Hmmm, you found a lost mine...",	@"Try Again", nil, nil);
    return self;
}

-(void) buttonPushed: sender
{
    int index = [fieldsList indexOfObject: sender];
    int xx, yy, aTag;
    int i, g;
    
    if (isRunning == NO || index == NSNotFound) {
		return;
    }

    xx = index % fh;
    yy = index / fh;
    aTag = [sender tag];
	
    if (aTag & (FLAG | CHECKED))
		return;

    switch ([sender tag]) {
		case 0:
			[self checkAtX: xx Y: yy];
			
			// if no timer, start a new one
			if (timerOn == NO) {
				timer = [NSTimer scheduledTimerWithTimeInterval: (NSTimeInterval) INTERVAL
														 target: self
													   selector: @selector(tick:)
													   userInfo: nil
														repeats: YES];
				timerOn = YES;
				NSBeep();
			}

			break;			
		case 1:
			for (i=0; i<fh; i++) {
				for (g=0; g<fw; g++) {
					[self checkOneAtX:g Y:i];
				}
			}
			
			[sender setImage: [NSImage imageNamed: @"brickPushedAndFalseBomb.tiff"]];
			NSBeep();
			
			// bang!
			[self endGame: NO];
			break;
    }

    if ( (maxspc == bombs) /* && ![bombDisplay intValue] */) {
		// Win !!!
		[self endGame: YES];
    }

    return;
}

-(void) rightButtonPushed: sender
{
    int index = [fieldsList indexOfObject: sender];
    int x, y, cnt, aTag;
    id obj;
	
    if (isRunning == NO || index == NSNotFound) {
		return;
    }
	
    x = index % fh;
    y = index / fh;
	
    cnt = x + (y*fw);
	
    obj = [fieldsList objectAtIndex: cnt];
    aTag = [obj tag];
	
    if (aTag & CHECKED)
		return;
	
    if (aTag & FLAG) {
		[obj setTag: (aTag - FLAG)];
		[obj setImage: [NSImage imageNamed: @"brick.tiff"]];
		[obj setEnabled: YES];
		[bombDisplay setIntValue: ([bombDisplay intValue] + 1)];
    } else {
		[obj setTag: (aTag | FLAG)];
		[obj setImage: [NSImage imageNamed: @"brickAndFlag.tiff"]];
		[obj setEnabled: NO];
		[bombDisplay setIntValue: ([bombDisplay intValue] - 1)];
    }
	
	//Win !!!
    if ( (maxspc == bombs) /* && ![bombDisplay intValue] */ ) {
		[self endGame: YES];
    }

    return;
}

-(int) tagOfX:(int)x Y:(int)y
{
    int aTag;

    if (x<0 || y < 0 || x>=fw || y>= fh) return INVALID;

    aTag = [[fieldsList objectAtIndex:(x+(y*fw))] tag]; 

    return aTag;
}

-(void) checkAtX:(int)xx Y:(int)yy
{
    int count = 0, i;
    id obj;

    if (xx<0 || yy < 0 || xx>=fw || yy>= fh) return;

    for (i=0; i<8; i++) {
		int c = [self tagOfX: (xx+dx[i]) Y: (yy+dy[i])];
		// if (c&FLAG) c-=FLAG;
		// if (c&CHECKED) c-=CHECKED;
		if ( (c != INVALID) && (c & ~(FLAG|CHECKED)) == 1)
			count++;
    }

    obj = [fieldsList objectAtIndex:(xx+(yy*fw))];

    [obj setTag: ([obj tag] | CHECKED)];
    [obj setImage: [NSImage imageNamed: iNumbers[count]]];
    [obj setEnabled: NO ];


    if (!count) {
		for (i=0; i<8; i++) {
			int c = [self tagOfX: (xx+dx[i]) Y: (yy+dy[i])];
			//if (!(c&(CHECKED|FLAG)))
			if ( (c != INVALID) && !(c & (CHECKED|FLAG)))
				[self checkAtX: (xx+dx[i]) Y: (yy+dy[i])];
		}
    }

    maxspc--;
}

-(void) checkOneAtX:(int)xx Y:(int)yy
{
    int count = 0, c, i;
    id obj;

    if (xx<0 || yy<0 || xx>=fw || yy>=fh) return;

    obj = [fieldsList objectAtIndex:(xx+(yy*fw))];

    c = [self tagOfX: xx Y: yy];

    if ( (c == INVALID) || (c & CHECKED)) return;
    if (c & FLAG) {
		c -= FLAG;
		if (c) [obj setImage: [NSImage imageNamed: @"brickPushedAndBomb.tiff"]];
		else [obj setImage: [NSImage imageNamed: @"brickPushedAndNoBomb.tiff"]];
		
		return;
    }

    if (c == 1) {
		[obj setImage: [NSImage imageNamed: @"brickPushedAndBomb.tiff"]];
		
    } else if (showAll == YES) {
		
		for (i=0; i<8; i++) {
			c = [self tagOfX: (xx+dx[i]) Y: (yy+dy[i])];
			if (c != INVALID) {
				//c &= ~(FLAG|CHECKED);
				if ( (c & (FLAG|CHECKED))==1) count++;
			}
		}
		
		[obj setImage: [NSImage imageNamed: iNumbers[count]]];
    }

    [obj setEnabled: NO ];
}



-(void) resetScores: sender
{
	int flag = NSRunAlertPanel(	@"Reset High Scores", @"Really ???", @"Yes",@"No",nil);
	if (flag == 0) return;

    [name0 setStringValue: @"Choler"];
    [time0 setIntValue: 999];
    [name1 setStringValue: @"Sang"];
    [time1 setIntValue: 999];
    [name2 setStringValue: @"Melan"];
    [time2 setIntValue: 999];
}

-(void) loadScores
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	if ([ud stringForKey: @"name0"]) {
		[name0 setStringValue: [ud stringForKey: @"name0"]];
		[time0 setIntValue: [ud integerForKey: @"time0"]];
	} else {
		[name0 setStringValue: @"Choler"];
		[time0 setIntValue: 999];
	}
	if ([ud stringForKey: @"name1"]) {
		[name1 setStringValue: [ud stringForKey: @"name1"]];
		[time1 setIntValue: [ud integerForKey: @"time1"]];
	} else {
		[name1 setStringValue: @"Sang"];
		[time1 setIntValue: 999];
	}
	if ([ud stringForKey: @"name2"]) {
		[name2 setStringValue: [ud stringForKey: @"name2"]];
		[time2 setIntValue: [ud integerForKey: @"time2"]];
	} else {
		[name2 setStringValue: @"Melan"];
		[time2 setIntValue: 999];
	}
}

-(void) saveScores
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

	[ud setObject:	[name0 stringValue]	forKey: @"name0"];
	[ud setInteger:	[time0 intValue]	forKey: @"time0"];
	[ud setObject:	[name1 stringValue]	forKey: @"name1"];
	[ud setInteger:	[time1 intValue]	forKey: @"time1"];
	[ud setObject:	[name2 stringValue]	forKey: @"name2"];
	[ud setInteger:	[time2 intValue]	forKey: @"time2"];

	[ud synchronize];
}

/* text delegate methods */

- (void)textDidEndEditing:(NSNotification *)aNotification;
{
    [actTextField setEditable: NO];
}

//- textDidChange: textObject
//{
//    NXColor Backgnd	= NXConvertRGBToColor(253, 136, 22);
//    NXColor Highlight	= NXConvertRGBToColor(253, 50, 10);

//    [textObject setBackgroundColor: Backgnd];
//    [textObject setBackgroundTransparent: YES];
//    [textObject setSelColor: Highlight];

//    return self;
//}

@end
