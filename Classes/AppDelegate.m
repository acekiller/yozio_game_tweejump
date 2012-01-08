#import "AppDelegate.h"
#import "Game.h"
#import "Main.h"
#import "Yozio.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  
  // Yozio
  [Yozio configure:@"tweejump"
            userId:@"MyUserId"
               env:@"production"
        appVersion:@"1.0.1"
  exceptionHandler:NULL];
  [Yozio newSession];

  
  
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//	[window setUserInteractionEnabled:YES];
//	[window setMultipleTouchEnabled:YES];	

	[[Director sharedDirector] setPixelFormat:kRGBA8];
	[[Director sharedDirector] attachInWindow:window];
//	[[Director sharedDirector] setDisplayFPS:YES];
	[[Director sharedDirector] setAnimationInterval:1.0/kFPS];

	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888]; 
	
	[window makeKeyAndVisible];

	Scene *scene = [[Scene node] addChild:[Game node] z:0];
	[[Director sharedDirector] runWithScene: scene];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}

- (void)applicationWillResignActive:(UIApplication*)application {
	[[Director sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
	[[Director sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

- (void)applicationSignificantTimeChange:(UIApplication*)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

@end
