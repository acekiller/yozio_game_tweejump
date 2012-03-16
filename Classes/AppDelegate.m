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

  
  // Yozio
  NSLog(@"applicationDidBecomeActive");
  NSLog(@"Configuration test");
  [Yozio configure:@"tweejump" secretKey:@"shhhhh"];
  [Yozio setApplicationVersion:@"1.0.1"];
  [Yozio setUserId:@"MyUserId"];
  [Yozio setApplicationVersion:@"1.0.1"];
  [Yozio setUserId:@"MyUserId"];
  [Yozio configure:@"tweejump" secretKey:@"shhhhh"];
  [Yozio setUserId:@"MyUserId"];
  [Yozio configure:@"tweejump" secretKey:@"shhhhh"];
  [Yozio setApplicationVersion:@"1.0.1"];
  [Yozio configure:@"tweejump" secretKey:@"shhhhh"];
  [Yozio setApplicationVersion:@"1.0.1"];
  [Yozio setUserId:@"MyUserId"];
  [Yozio setApplicationVersion:@"1.0.1"];
  [Yozio setUserId:@"MyUserId"];
  [Yozio configure:@"tweejump" secretKey:@"shhhhh"];
  [Yozio setUserId:@"MyUserId"];
//  [Yozio getInstance].dataQueue = [NSMutableArray array];
  

  NSLog(@"Data Queue Size %d. Should be 0", [[Yozio getInstance].dataQueue count]);

  // endTimer
  [Yozio endTimer:@"applicationDidBecomeActive"];
  NSLog(@"Data Queue Size %d. Should be 0", [[Yozio getInstance].dataQueue count]);

  
//  Start Timer, End Timer
  [Yozio startTimer:@"applicationDidBecomeActive"];
  [NSThread sleepForTimeInterval:2];
  [Yozio endTimer:@"applicationDidBecomeActive"];
  NSLog(@"Data Queue Size %d. Should be 1", [[Yozio getInstance].dataQueue count]);

  //  Start Timer, Start Timer. End Timer, End Timer
  [Yozio startTimer:@"applicationDidBecomeActive"];
  [Yozio startTimer:@"applicationDidBecomeActive"];
  [Yozio endTimer:@"applicationDidBecomeActive"];
  [Yozio endTimer:@"applicationDidBecomeActive"];
  NSLog(@"Data Queue Size %d. Should be 2", [[Yozio getInstance].dataQueue count]);

  //  Start Timer, Collect Action, End Timer
  [Yozio startTimer:@"applicationDidBecomeActive"];
  [Yozio action:@"cat.balou"];
  [Yozio endTimer:@"applicationDidBecomeActive"];
  NSLog(@"Data Queue Size %d. Should be 4", [[Yozio getInstance].dataQueue count]);

  
  //  Start Timer, Collect Action, Background, End Timer
  [Yozio startTimer:@"applicationDidBecomeActive"];
  [Yozio action:@"cat.balou"];
  NSLog(@"BACKGROUND THE APP NOW");
  [NSThread sleepForTimeInterval:5]; //Time for us to background it.
  [Yozio endTimer:@"applicationDidBecomeActive"];
  NSLog(@"Data Queue Size %d. Should be 4", [[Yozio getInstance].dataQueue count]);
  
  //  Start Timer, Background the App, End Timer
  [Yozio startTimer:@"applicationDidBecomeActive"];
  [Yozio action:@"cat.balou"];
  NSLog(@"BACKGROUND/QUIT THE APP NOW");
  [NSThread sleepForTimeInterval:5]; //Time for us to background it.
//End Timer is on line 73.
  
  NSLog(@"Time for it to send once. Check logs to ensure only 1 flush is called");
  [NSThread sleepForTimeInterval:15]; 

  // Stress Test
  NSInteger prev = [[Yozio getInstance].dataQueue count];
  NSInteger prevDataCount = [Yozio getInstance].dataCount;
  for(int i=0;i<6000;i++){
    if (i%100==0) {
      NSLog(@"%d", i); 
    }
    [Yozio action:@"drink LC"];
  }
  NSLog(@"total number of events added to dataQueue from stress test %d. Should be 5000 - %d", [[Yozio getInstance].dataQueue count], prev);
  NSLog(@"total number of events counted from stress test %d. Should be 6000", [Yozio getInstance].dataCount - prevDataCount);

  
  
  
  
  
  
  NSLog(@"recommendationOrder %@", [Yozio stringForKey:@"recommendationOrder" defaultValue:@"default"]);
  NSLog(@"buyBirds %@", [Yozio stringForKey:@"buyBirds" defaultValue:@"default"]);
  
  
  
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
  
  
  //
  window = [[PaintingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [[Director sharedDirector] attachInWindow:window];
  [window makeKeyAndVisible];
  
  
	Scene *scene = [[Scene node] addChild:[Game node] z:0];
	[[Director sharedDirector] runWithScene:scene];
  
  NSBundle *mainBundle = [NSBundle mainBundle];	
	erasingSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
  
  // setup sound
  Bird *myBird = [Bird sharedInstance];
  
  
  NSLog(@"bird %@", [myBird getType]);
  NSLog(@"loaded sound, %@", [myBird getMusic]);
  [erasingSound play];
  
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
