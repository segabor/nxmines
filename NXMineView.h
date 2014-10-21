
#import <appkit/appkit.h>

#define BEGINNER 0
#define MEDIUM 1
#define EXPERT 2

#define CHECKED 0x04
#define FLAG 0x08

#define INTERVAL 1
#define PRIORITY 1

void timer(DPSTimedEntry tEntry, double now, void *udata);

@interface NXMineView:View
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
}

- initFrame:(const NXRect *)aRect;
- postInit: sender;
- (BOOL)acceptsFirstResponder;
- rightMouseDown:(NXEvent *)theEvent;
- setBeginner:sender;
- setMedium:sender;
- setExpert:sender;
- setGameMode:(int)mode;
- initFieldsW:(int)w H:(int)h Bombs:(int)Bombs;
- startGame:sender;
- endGame:(BOOL)win;
- buttonPushed: sender;
-(int) tagOfX:(int)x Y:(int)y;
- checkAtX:(int)xx Y:(int)yy;
- checkOneAtX:(int)xx Y:(int)yy;
- loadScores;
- saveScores;
- resetScores: sender;
- read:(NXStream *)aStream;
- write:(NXStream *)aStream;
/* text delegators */
- textDidEnd:textObject endChar:(unsigned short)whyEnd;
//- textDidChange: textObject;
@end
