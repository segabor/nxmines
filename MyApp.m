
#import "MyApp.h"

@implementation MyApp

- appDidInit: sender
{
    [mineView postInit: self];
    [gameWindow makeKeyAndOrderFront: self];
    return self;
}

- windowWillClose: sender
{
    [mineView saveScores];
    [gameWindow setDelegate: nil];
    [gameWindow performClose: self];

    return [self terminate: self];
}

// TODO: write terminate: method ...