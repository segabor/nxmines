
#import "MyWindow.h"

@implementation MyWindow

- windowWillClose: sender
{
    [self setDelegate: self];
    return [NXApp terminate];
}

@end
