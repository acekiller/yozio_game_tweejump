#import "AppDelegate.h"
#import "Game.h"
#import "Main.h"
#import "Yozio.h"
#import "Yozio_Private.h"
#import "Apsalar.h"
#import "AVFoundation/AVFoundation.h"
#import "SoundEffect.h"
#import "Bird.h"
#import "Highscores.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  //	[window setUserInteractionEnabled:YES];
  //	[window setMultipleTouchEnabled:YES];	
  [Yozio configure:@"ca2e6ac0-d2d4-012f-2c29-12314000ac7c" secretKey:@"ca2e73c0-d2d4-012f-2c2a-12314000ac7c"];
  [Yozio initializeExperiments];
	[[Director sharedDirector] setPixelFormat:kRGBA8];
	
  //	[[Director sharedDirector] setDisplayFPS:YES];
	[[Director sharedDirector] setAnimationInterval:1.0/kFPS];
  
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888]; 
}

// Called when receiving the "shake" notification; plays the erase sound and redraws the view
-(void) changeBirdView
{
  NSLog(@"SHAKE");
  [erasingSound play];
  NSArray *birdTypes = [NSArray arrayWithObjects:@"pig", @"newt", @"yellowbird", @"redbird", @"cuttherope", @"obama", @"mittromney", nil];
  int i = random()%birdTypes.count;
  NSString *type = [birdTypes objectAtIndex:i];
  [self updateBirdAndStartGame:type];
}


- (void)dealloc {
	[window release];
	[super dealloc];
}

- (void)applicationWillResignActive:(UIApplication*)application {
  [player dealloc];
	[[Director sharedDirector] end];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
  
  
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

  
  //
  window = [[PaintingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [[Director sharedDirector] attachInWindow:window];
  [window makeKeyAndVisible];
  
  
	Scene *scene = [[Scene node] addChild:[Game node] z:0];
	[[Director sharedDirector] runWithScene:scene];
  
  
}

- (void)updateBirdAndStartGame:(NSString*)type {
  NSLog(@"%@ selected", type);
  NSLog(@"Setting bird type from %@ to %@", [[Bird sharedInstance] getType], type);
  Bird *bird = [Bird sharedInstance];
  [bird setType:type];
  //	Scene *scene = [[Scene node] addChild:[Game node] z:0];
  //	TransitionScene *ts = [FadeTransition transitionWithDuration:0.5f scene:scene withColorRGB:0xffffff];
  //	[[Director sharedDirector] replaceScene:ts];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

- (void)applicationSignificantTimeChange:(UIApplication*)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

@end
