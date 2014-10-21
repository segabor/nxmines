#import <appkit/appkit.h>
#import "NXMineView.h"

@interface MyApp:Application
{
    id	gameWindow;
    id	mineView;
}

- appDidInit: sender;
- windowWillClose: sender;

@end
