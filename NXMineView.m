
#import "NXMineView.h"
#import <appkit/graphics.h>

id fieldsList;
int gameMode;
BOOL isRunning = NO;
BOOL timerOn = NO;
int bombs;
int fw, fh, fc;
int maxspc;
int temp;
DPSTimedEntry tEntry;

id actTextField = nil;

const char *Fname = {".NXMines"};
BOOL showAll = NO;

int dx[] = {-1,  0,  1, -1, 1, -1, 0, 1};
int dy[] = {-1, -1, -1,  0, 0,  1, 1, 1};

const char *numbers[] = {" ", "1", "2", "3", "4", "5", "6", "7", "8"};
const char *iNumbers[] = {
	"brickPushed.tiff",
	"brick1.tiff",
	"brick2.tiff",
	"brick3.tiff",
	"brick4.tiff",
	"brick5.tiff",
	"brick6.tiff",
	"brick7.tiff",
	"brick8.tiff"};

const char s0[128], s1[128], s2[128];
char *sp0 = (char *)&s0[0];
char *sp1 = (char *)&s1[0];
char *sp2 = (char *)&s2[0];

@implementation NXMineView

void timer(DPSTimedEntry tEntry, double now, void *udata)
{
    id tD = (id)udata;

    temp++;
    [tD setIntValue: temp];
    if (temp == 999) {
	DPSRemoveTimedEntry(tEntry);
	timerOn = NO;
    }
    return;
}

- initFrame:(const NXRect *)aRect
{
    [super initFrame:aRect];

    gameMode = BEGINNER;
    isRunning = NO;
    fieldsList = [List new];
    
    return self;
}

- postInit: sender
{
    [self loadScores];

    [name0 setTextDelegate: self];
    [name1 setTextDelegate: self];
    [name2 setTextDelegate: self];
    [self setGameMode: gameMode];
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- rightMouseDown:(NXEvent *)theEvent
{
    NXPoint aP;
    int x, y, cnt, aTag;
    id obj;

    if (isRunning == NO) return self;

    aP.x = theEvent->location.x;
    aP.y = theEvent->location.y;
    [self convertPoint:&aP fromView:nil];

    x = (aP.x)/18;
    y = (aP.y)/18;
    cnt = x + (y*fw);

    obj = [fieldsList objectAt: cnt];
    aTag = [obj tag];

    if (aTag & CHECKED)
	return self;

    if (aTag & FLAG) {
	[obj setTag: (aTag - FLAG)];
	[obj setIcon: "brick.tiff"];
	[obj setEnabled: YES];
	[bombDisplay setIntValue: ([bombDisplay intValue] + 1)];
    } else {
	[obj setTag: (aTag | FLAG)];
	[obj setIcon: "brickAndFlag.tiff"];
	[obj setEnabled: NO];
	[bombDisplay setIntValue: ([bombDisplay intValue] - 1)];
    }

    [obj display];
//Win !!!
    if ( (maxspc == bombs) & ![bombDisplay intValue]) {
	[self endGame: YES];
    }


    return self;
}

- initFieldsW:(int)w H:(int)h Bombs:(int)Bombs
{
    int i, g;
    id obj;
    NXRect aRect;

    [self setAutodisplay: NO];

    bombs = Bombs;
    fw = w;
    fh = h;
    fc = w*h;

    [[self window] sizeWindow: 16 + (fw*18)
			     : 16 + 64 + (fh*18)];

    [self getFrame: &aRect];
    aRect.size.width = (fw*18);
    aRect.size.height = (fh*18);
    [self setFrame: &aRect];

    [[self window] display];

    for (i=0; i<h ; i++) {
	for (g=0; g<w; g++) {
	    obj = [Button new];

	    NXSetRect(&aRect, (g*18), (i*18), 18, 18);
	    [obj initFrame:&aRect
		title:""
		tag:0
		target: self
		action: @selector(buttonPushed:)
		key: 0x00
		enabled: YES];
	    [obj setType: NX_MOMENTARYCHANGE];
	    [obj setAutodisplay: NO];
	    [obj setIcon: "brick.tiff"];
	    [obj setAltIcon: "brickPushed.tiff"];
	    [obj setBordered: NO];
	    [self addSubview: obj];
	    [fieldsList addObject: obj];
	}
    }


    [self setAutodisplay: YES];
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

    if ([fieldsList count]>0)
	for (i=0; i<[fieldsList count]; i++) {
	    [[fieldsList objectAt: i] removeFromSuperview];

	[fieldsList freeObjects];
	}

    gameMode = mode;

    switch (gameMode) {
	case BEGINNER:
	[self initFieldsW:10 H:10 Bombs: 10];
	[[self window] setTitle: "NXMines - Beginner"];
	break;
	case MEDIUM:
	[self initFieldsW:20 H:20 Bombs: 60];
	[[self window] setTitle: "NXMines - Medium"];
	break;
	case EXPERT:
	[self initFieldsW:20 H:20 Bombs: 100];
	[[self window] setTitle: "NXMines - Expert"];
	break;
	default: 
	[self initFieldsW:10 H:10 Bombs: 10];
	[[self window] setTitle: "NXMines - Beginner"];
	break;
   }

    [self startGame: self];
    [self display];
    NXPing();
    return self;
}

- startGame:sender
{
    int i;
    int rnd;
    id obj;

    [self setAutodisplay: NO];

    if (timerOn == YES) {
	DPSRemoveTimedEntry(tEntry);
	timerOn = NO;
    }

    for (i=0; i<[fieldsList count]; i++) {
	obj = [fieldsList objectAt: i];
	[obj setTag: 0];
	[obj setEnabled: YES];
	[obj setIcon: "brick.tiff"];
   }

    for (i=0; i<bombs; i++) {
	do {
	    rnd = (int)(random() % fc);
	} while ([[fieldsList objectAt: rnd] tag] == 1);

	[[fieldsList objectAt: rnd] setTag: 1];
    }

    [self setAutodisplay: YES];
    isRunning = YES;

    [bombDisplay setIntValue: bombs];
    [timeDisplay setIntValue: 0];
    [scorePanel display];

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
    if (timerOn == YES) DPSRemoveTimedEntry(tEntry);
    timerOn = NO;

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
	    NXRunAlertPanel("You Won!!", "... and you made best time!",
	    				"OK", 0, 0);
	    [tm setIntValue: temp];
	    [nm setEditable: YES];
//	    [nm selectAll: self];
	    [scorePanel makeKeyAndOrderFront: self];
	    actTextField = nm;	    
	} else
	    NXRunAlertPanel("You Won!", "Wow, you made it!",
	    				"OK", 0, 0);
    } else
	NXRunAlertPanel("You Blasted!", "Hmmm, you found a lost mine...",
	    				"Try Again", 0, 0);
    return self;
}

- buttonPushed: sender
{
    int index = [fieldsList indexOf: sender];
    int xx = index % fh;
    int yy = index / fh;
    int i, g;
    int aTag = [sender tag];
    
    if (isRunning == NO) {
	[sender display];
	return self;
    }

    if (aTag & FLAG)
	return self;

    if (aTag & CHECKED)
	return self;

    switch ([sender tag]) {
	case 0:
	[self checkAtX: xx Y: yy];

	if (timerOn == NO) {
	    tEntry = DPSAddTimedEntry(INTERVAL, timer,
					(char *)timeDisplay, PRIORITY);
	    timerOn = YES;
	NXPing();
	}

	break;

	case 1:
	for (i=0; i<fh; i++)
	    for (g=0; g<fw; g++) {
		[self checkOneAtX:g Y:i];
	    }

	[sender setIcon: "brickPushedAndFalseBomb.tiff"];
	NXPing();

	[self display];
	[self endGame: NO];	//BANG!!!!
	break;
    }

//Win !!!
    if ( (maxspc == bombs) & ![bombDisplay intValue]) {
	[self endGame: YES];
    }


    return self;
}

-(int) tagOfX:(int)x Y:(int)y
{
    int aTag;

    if (x<0) return -1;
    if (y<0) return -1;
    if (x>=fw) return -1;
    if (y>=fh) return -1;

    aTag = [[fieldsList objectAt:(x+(y*fw))] tag]; 

//    if (aTag & CHECKED)
//	return -1;

//    if (aTag & FLAG)
//	return -1;

    return aTag;
}

- checkAtX:(int)xx Y:(int)yy
{
    int count = 0, c, i;
    id obj;

    if (xx<0) return self;
    if (yy<0) return self;
    if (xx>=fw) return self;
    if (yy>=fh) return self;

    for (i=0; i<8; i++) {
	c=[self tagOfX: (xx+dx[i]) Y: (yy+dy[i])];
	if (c&FLAG) c-=FLAG;
	if (c&CHECKED) c-=CHECKED;
	if (c==1) count++;
    }

    obj = [fieldsList objectAt:(xx+(yy*fw))];

    [obj setTag: ([obj tag] | CHECKED)];
    [obj setIcon: iNumbers[count]];
    [obj setEnabled: NO ];
    [obj display];


    if (!count) {
	for (i=0; i<8; i++) {
	    c=[self tagOfX: (xx+dx[i]) Y: (yy+dy[i])];
	    if (!(c&(CHECKED|FLAG)))
	        if (!c) [self checkAtX: (xx+dx[i]) Y: (yy+dy[i])];
	}
    }

    maxspc--;
    return self;
}

- checkOneAtX:(int)xx Y:(int)yy
{
    int count = 0, c, i;
    id obj;

    if (xx<0) return self;
    if (yy<0) return self;
    if (xx>=fw) return self;
    if (yy>=fh) return self;

    obj = [fieldsList objectAt:(xx+(yy*fw))];

    c=[self tagOfX: xx Y: yy];

    if (c & CHECKED) return self;
    if (c & FLAG) {
	c -= FLAG;
	if (c) [obj setIcon: "brickPushedAndBomb.tiff"];
	else [obj setIcon: "brickPushedAndNoBomb.tiff"];

	return self;
    }

    if (c==1) {
	[obj setIcon: "brickPushedAndBomb.tiff"];

    } else if (showAll == YES) {

	for (i=0; i<8; i++) {
	    c=[self tagOfX: (xx+dx[i]) Y: (yy+dy[i])];
	    c &= ~(FLAG+CHECKED);
	    if (c==1) count++;
	}

	[obj setIcon: iNumbers[count]];
    }

    [obj setEnabled: NO ];

    return self;
}


- loadScores
{
    NXTypedStream *aStream = NXOpenTypedStreamForFile (Fname, NX_READONLY);
    int i0, i1, i2;
    int x0, y0, x1, y1;
    NXRect aRect;

    if (aStream != NULL) {
	NXReadTypes(aStream, "iii***iiiii",
		&i0, &i1, &i2,
		&sp0, &sp1, &sp2,
		&gameMode,
		&x0, &y0, &x1, &y1
		);

//	[[self window] read: aStream];
//	[scorePanel read: aStream];

	NXCloseTypedStream(aStream);

	[name0 setStringValue: sp0];
	[time0 setIntValue: i0];
	[name1 setStringValue: sp1];
	[time1 setIntValue: i1];
	[name2 setStringValue: sp2];
	[time2 setIntValue: i2];

	[[self window] getFrame: &aRect];
	aRect.origin.x = (NXCoord)x0;
	aRect.origin.y = (NXCoord)y0;
	[[self window] placeWindow: &aRect];

	[scorePanel getFrame: &aRect];
	aRect.origin.x = (NXCoord)x1;
	aRect.origin.y = (NXCoord)y1;
	[scorePanel placeWindow: &aRect];

    } else
	[self resetScores: nil];
    
    return self;
}

- saveScores
{
    NXTypedStream *aStream;
    int i0, i1, i2;
    int x0, y0, x1, y1;

    NXRect aRect;

    aStream = NXOpenTypedStreamForFile (Fname, NX_WRITEONLY);

    if (aStream == NULL)
	NXRunAlertPanel("File Error", "Couldn't save High Scores", "Ugh !",
		NULL, NULL);
    else {
	i0 = [time0 intValue];
	i1 = [time1 intValue];
	i2 = [time2 intValue];
	strcpy(sp0, [name0 stringValue]);
	strcpy(sp1, [name1 stringValue]);
	strcpy(sp2, [name2 stringValue]);

	[[self window] getFrame: &aRect];
	x0 = (int)(aRect.origin.x);
	y0 = (int)(aRect.origin.y);
	[scorePanel getFrame: &aRect];
	x1 = (int)(aRect.origin.x);
	y1 = (int)(aRect.origin.y);

	NXWriteTypes(aStream, "iii***iiiii",
			&i0, &i1, &i2,
			&sp0, &sp1, &sp2,
			&gameMode,
			&x0, &y0, &x1, &y1
			);

//	[[self window] write: aStream];
//	[scorePanel write: aStream];

	NXCloseTypedStream(aStream);
    }
    return self;
}

- resetScores: sender
{
    int flag;

    if (sender!=nil) {
	flag = NXRunAlertPanel(	"Reset High Scores",
				"Really ???", "Yes","No",0);
	if (flag == 0) return self;
    }

    [name0 setStringValue: "Choler"];
    [time0 setIntValue: 999];
    [name1 setStringValue: "Sang"];
    [time1 setIntValue: 999];
    [name2 setStringValue: "Melan"];
    [time2 setIntValue: 999];

    return self;
}

- read:(NXStream *)aStream
{
    printf("Trying to read...\n");
    [super read:aStream];
    return self;
}

- write:(NXStream *)aStream
{
    printf("Trying to write...\n");
    [super read:aStream];
    return self;
}

/* text delegate methods */

- textDidEnd:textObject endChar:(unsigned short)whyEnd
{
    [actTextField setEditable: NO];
    [scorePanel display];
    printf("char: 0x%x\n", whyEnd);
    return self;
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
