#import "cocos2d.h"
#import "PaintingWindow.h"
#import "AVFoundation/AVFoundation.h"
#import "SoundEffect.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate>
{
	PaintingWindow *window;

  SoundEffect			*erasingSound;
  SoundEffect			*bs;
	SoundEffect			*selectSound;
  AVAudioPlayer   *player;
}
@end
