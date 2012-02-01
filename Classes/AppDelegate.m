#import "AppDelegate.h"
#import "Game.h"
#import "Main.h"
#import "Yozio.h"
#import "Apsalar.h"
#import "AVFoundation/AVFoundation.h"
#import "SoundEffect.h"
#import "Bird.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  
  // Yozio
  [Yozio configure:@"tweejump"
            userId:@"MyUserId"
               env:@"production"
        appVersion:@"1.0.1"
  exceptionHandler:NULL];
//  [Yozio newSession];

  
  
  
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

	window = [[PaintingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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

  NSBundle *mainBundle = [NSBundle mainBundle];	
	erasingSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];

//  bs = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"bs" ofType:@"mp3"]];
//  [bs play];
//  
  
  NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"bs" ofType:@"mp3"];
  NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
  AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
  player.numberOfLoops = -1; //infinite
  
  [player play];

  Bird *myBird = [Bird sharedInstance];
  
  NSLog(@"bird %@", [myBird getType]);
  NSLog(@"loaded sound");
  [erasingSound play];
  // Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
	// The "shake" nofification is posted by the PaintingWindow object when user shakes the device
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBirdView) name:@"shake" object:nil];

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
