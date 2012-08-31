#import "Game.h"
#import "Main.h"
#import "Highscores.h"
#import "Yozio.h"
#import "Bird.h"
#import "AppDelegate.h"

@interface Game (Private)
- (void)initPlatforms;
- (void)initPlatform;
- (void)startGame;
- (void)resetPlatforms;
- (void)resetPlatform;
- (void)resetBird;
- (void)resetBonus;
- (void)step:(ccTime)dt;
- (void)jump;
- (void)showHighscores;
@end


@implementation Game

- (id)init {
  
	NSLog(@"Game::init");
  
	if(![super init]) return nil;
	
	gameSuspended = YES;

	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];

	[self initPlatforms];
	
  // TODO (jimmy): change this to read in from yozio_config from server. make it change to pig. Always remember to add 10 px to the height for some reason.
//	AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(608,16,44,32) spriteManager:spriteManager];
//pig 
  Bird *birdType = [Bird sharedInstance];
  NSLog(@"birdtype %@", [birdType getType]);
  
  if ( [birdType getType] == @"pig" || [[Yozio stringForKey:@"characterStartType" defaultValue:@"default"] isEqualToString:@"pig"]) { 
    [birdType setType:@"pig"];
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(674,6,716-674,58-6) spriteManager:spriteManager]; 
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  } else if ([birdType getType] == @"newt"){
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(861,55,902-861,115-65) spriteManager:spriteManager];
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  } else if ([birdType getType] == @"obama" || [[Yozio stringForKey:@"characterStartType" defaultValue:@"default"] isEqualToString:@"obama"]){
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(795,57,828-795,120-65) spriteManager:spriteManager];
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  } else if ([birdType getType] == @"mittromney"){
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(730,67,767-730,120-65) spriteManager:spriteManager];
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  } else if ([birdType getType] == @"cuttherope"){
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(862,16,905-862,70-16) spriteManager:spriteManager];
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  } else if ([birdType getType] == @"redbird"){
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(795,16,840-795,65-15) spriteManager:spriteManager];
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  } else if ([birdType getType] == @"yellowbird"){
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(735,16,770-735,60-15) spriteManager:spriteManager];
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  } else {
    AtlasSprite *bird = [AtlasSprite spriteWithRect:CGRectMake(608,16,44,32) spriteManager:spriteManager];
    NSLog(@"bird.parent %@", bird.parent);
    [spriteManager addChild:bird z:4 tag:kBird];
  }

	AtlasSprite *bonus;

	for(int i=0; i<kNumBonuses; i++) {
		bonus = [AtlasSprite spriteWithRect:CGRectMake(608+i*32,256,25,25) spriteManager:spriteManager];
		[spriteManager addChild:bonus z:4 tag:kBonusStartTag+i];
		bonus.visible = NO;
	}

    // LabelAtlas *scoreLabel = [LabelAtlas labelAtlasWithString:@"0" charMapFile:@"charmap.png" itemWidth:24 itemHeight:32 startCharMap:' '];
    // [self addChild:scoreLabel z:5 tag:kScoreLabel];
	
	BitmapFontAtlas *scoreLabel = [BitmapFontAtlas bitmapFontAtlasWithString:@"0" fntFile:@"bitmapFont.fnt"];
	[self addChild:scoreLabel z:5 tag:kScoreLabel];
	scoreLabel.position = ccp(160,430);

  // setup bg music

  if ([[Yozio stringForKey:@"musicOn" defaultValue:@"false"] isEqualToString:@"true"]) {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:[Yozio stringForKey:@"musicStartType" defaultValue:@"bs"] ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    appDelegate->player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    appDelegate->player.numberOfLoops = -1; //infinite = -1
    [appDelegate->player play];
  }
  
  
	[self schedule:@selector(step:)];
	
	isTouchEnabled = NO;
	isAccelerometerEnabled = YES;

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kFPS)];
	
	[self startGame];
	
	return self;
}

- (void)dealloc {
	NSLog(@"Game::dealloc");
	
  [super dealloc];
}

- (void)initPlatforms {
	//NSLog(@"initPlatforms");
	
	currentPlatformTag = kPlatformsStartTag;
	while(currentPlatformTag < kPlatformsStartTag + kNumPlatforms) {
		[self initPlatform];
		currentPlatformTag++;
	}
	
	[self resetPlatforms];
}

- (void)initPlatform {

	CGRect rect;
	switch(random()%2) {
		case 0: rect = CGRectMake(608,64,102,36); break;
		case 1: rect = CGRectMake(608,128,90,32); break;
	}

	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
	AtlasSprite *platform = [AtlasSprite spriteWithRect:rect spriteManager:spriteManager];
	[spriteManager addChild:platform z:3 tag:currentPlatformTag];
}

- (void)startGame {
	//NSLog(@"startGame");  

	score = 0;
	
	[self resetClouds];
	[self resetPlatforms];
	[self resetBird];
	[self resetBonus];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	gameSuspended = NO;
}

- (void)resetPlatforms {
	//NSLog(@"resetPlatforms");
	
	currentPlatformY = -1;
	currentPlatformTag = kPlatformsStartTag;
	currentMaxPlatformStep = 60.0f;
	currentBonusPlatformIndex = 0;
	currentBonusType = 0;
	platformCount = 0;

	while(currentPlatformTag < kPlatformsStartTag + kNumPlatforms) {
		[self resetPlatform];
		currentPlatformTag++;
	}
}

- (void)resetPlatform {
	
	if(currentPlatformY < 0) {
		currentPlatformY = 30.0f;
	} else {
		currentPlatformY += random() % (int)(currentMaxPlatformStep - kMinPlatformStep) + kMinPlatformStep;
		if(currentMaxPlatformStep < kMaxPlatformStep) {
			currentMaxPlatformStep += 0.5f;
		}
	}
	
	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
	AtlasSprite *platform = (AtlasSprite*)[spriteManager getChildByTag:currentPlatformTag];
	
	if(random()%2==1) platform.scaleX = -1.0f;
	
	float x;
	CGSize size = platform.contentSize;
	if(currentPlatformY == 30.0f) {
		x = 160.0f;
	} else {
		x = random() % (320-(int)size.width) + size.width/2;
	}
	
	platform.position = ccp(x,currentPlatformY);
	platformCount++;
	

	if(platformCount == currentBonusPlatformIndex) {
//		NSLog(@"platformCount == currentBonusPlatformIndex");
		AtlasSprite *bonus = (AtlasSprite*)[spriteManager getChildByTag:kBonusStartTag+currentBonusType];
		bonus.position = ccp(x,currentPlatformY+30);
		bonus.visible = YES;
	}
}

- (void)resetBird {
	//NSLog(@"resetBird");

	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
	AtlasSprite *bird = (AtlasSprite*)[spriteManager getChildByTag:kBird];
	
	bird_pos.x = 160;
	bird_pos.y = 160;
	bird.position = bird_pos;
	
	bird_vel.x = 0;
	bird_vel.y = 0;
	
	bird_acc.x = 0;
	bird_acc.y = -550.0f;
	
	birdLookingRight = YES;
	bird.scaleX = 1.0f;
}

- (void)resetBonus {
	//NSLog(@"resetBonus");
	
	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
	AtlasSprite *bonus = (AtlasSprite*)[spriteManager getChildByTag:kBonusStartTag+currentBonusType];
	bonus.visible = NO;
	currentBonusPlatformIndex += random() % (kMaxBonusStep - kMinBonusStep) + kMinBonusStep;
	if(score < 10000) {
		currentBonusType = 0;
	} else if(score < 50000) {
		currentBonusType = random() % 2;
	} else if(score < 100000) {
		currentBonusType = random() % 3;
	} else {
		currentBonusType = random() % 2 + 2;
	}
}

- (void)step:(ccTime)dt {
//	NSLog(@"Game::step");

	[super step:dt];
	
	if(gameSuspended) return;

	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
	AtlasSprite *bird = (AtlasSprite*)[spriteManager getChildByTag:kBird];
	
	bird_pos.x += bird_vel.x * dt;
	
	if(bird_vel.x < -30.0f && birdLookingRight) {
		birdLookingRight = NO;
		bird.scaleX = -1.0f;
	} else if (bird_vel.x > 30.0f && !birdLookingRight) {
		birdLookingRight = YES;
		bird.scaleX = 1.0f;
	}

	CGSize bird_size = bird.contentSize;
	float max_x = 320-bird_size.width/2;
	float min_x = 0+bird_size.width/2;
	
	if(bird_pos.x>max_x) bird_pos.x = max_x;
	if(bird_pos.x<min_x) bird_pos.x = min_x;
	
	bird_vel.y += bird_acc.y * dt;
	bird_pos.y += bird_vel.y * dt;
	
	AtlasSprite *bonus = (AtlasSprite*)[spriteManager getChildByTag:kBonusStartTag+currentBonusType];
	if(bonus.visible) {
		CGPoint bonus_pos = bonus.position;
		float range = 20.0f;
		if(bird_pos.x > bonus_pos.x - range &&
		   bird_pos.x < bonus_pos.x + range &&
		   bird_pos.y > bonus_pos.y - range &&
		   bird_pos.y < bonus_pos.y + range ) {
			switch(currentBonusType) {
				case kBonus5:   score += 5000;   break;
				case kBonus10:  score += 10000;  break;
				case kBonus50:  score += 50000;  break;
				case kBonus100: score += 100000; break;
			}
			NSString *scoreStr = [NSString stringWithFormat:@"%d",score];
			BitmapFontAtlas *scoreLabel = (BitmapFontAtlas*)[self getChildByTag:kScoreLabel];
			[scoreLabel setString:scoreStr];
			id a1 = [ScaleTo actionWithDuration:0.2f scaleX:1.5f scaleY:0.8f];
			id a2 = [ScaleTo actionWithDuration:0.2f scaleX:1.0f scaleY:1.0f];
			id a3 = [Sequence actions:a1,a2,a1,a2,a1,a2,nil];
			[scoreLabel runAction:a3];
			[self resetBonus];
		}
	}
	
	int t;
	
	if(bird_vel.y < 0) {
		
		t = kPlatformsStartTag;
		for(t; t < kPlatformsStartTag + kNumPlatforms; t++) {
			AtlasSprite *platform = (AtlasSprite*)[spriteManager getChildByTag:t];

			CGSize platform_size = platform.contentSize;
			CGPoint platform_pos = platform.position;
			
			max_x = platform_pos.x - platform_size.width/2 - 10;
			min_x = platform_pos.x + platform_size.width/2 + 10;
			float min_y = platform_pos.y + (platform_size.height+bird_size.height)/2 - kPlatformTopPadding;
			
			if(bird_pos.x > max_x &&
			   bird_pos.x < min_x &&
			   bird_pos.y > platform_pos.y &&
			   bird_pos.y < min_y) {
				[self jump];
			}
		}
		
		if(bird_pos.y < -bird_size.height/2) {
			[self showHighscores];
		}
		
	} else if(bird_pos.y > 240) {
		
		float delta = bird_pos.y - 240;
		bird_pos.y = 240;

		currentPlatformY -= delta;
		
		t = kCloudsStartTag;
		for(t; t < kCloudsStartTag + kNumClouds; t++) {
			AtlasSprite *cloud = (AtlasSprite*)[spriteManager getChildByTag:t];
			CGPoint pos = cloud.position;
			pos.y -= delta * cloud.scaleY * 0.8f;
			if(pos.y < -cloud.contentSize.height/2) {
				currentCloudTag = t;
				[self resetCloud];
			} else {
				cloud.position = pos;
			}
		}
		
		t = kPlatformsStartTag;
		for(t; t < kPlatformsStartTag + kNumPlatforms; t++) {
			AtlasSprite *platform = (AtlasSprite*)[spriteManager getChildByTag:t];
			CGPoint pos = platform.position;
			pos = ccp(pos.x,pos.y-delta);
			if(pos.y < -platform.contentSize.height/2) {
				currentPlatformTag = t;
				[self resetPlatform];
			} else {
				platform.position = pos;
			}
		}
		
		if(bonus.visible) {
			ccVertex2F pos = bonus.position;
			pos.y -= delta;
			if(pos.y < -bonus.contentSize.height/2) {
				[self resetBonus];
			} else {
				bonus.position = pos;
			}
		}
		
		score += (int)delta;
		NSString *scoreStr = [NSString stringWithFormat:@"%d",score];

		BitmapFontAtlas *scoreLabel = (BitmapFontAtlas*)[self getChildByTag:kScoreLabel];
		[scoreLabel setString:scoreStr];
	}
	
	bird.position = bird_pos;
}

- (void)jump {
	bird_vel.y = 350.0f;
//  	bird_vel.y = 350.0f + fabsf(bird_vel.x);
}

- (void)showHighscores {
	//NSLog(@"showHighscores");
	gameSuspended = YES;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
	NSLog(@"score = %d",score);
  
	Highscores *highscores = [[Highscores alloc] initWithScore:score];

	Scene *scene = [[Scene node] addChild:highscores z:0];
	[[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:1 scene:scene withColorRGB:0xffffff]];
}

//- (BOOL)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
//	NSLog(@"ccTouchesEnded");
//
////	[self showHighscores];
//
////	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
////	AtlasSprite *bonus = (AtlasSprite*)[spriteManager getChildByTag:kBonus];
////	bonus.position = ccp(160,30);
////	bonus.visible = !bonus.visible;
//
////	BitmapFontAtlas *scoreLabel = (BitmapFontAtlas*)[self getChildByTag:kScoreLabel];
////	id a1 = [ScaleTo actionWithDuration:0.2f scaleX:1.5f scaleY:0.8f];
////	id a2 = [ScaleTo actionWithDuration:0.2f scaleX:1.0f scaleY:1.0f];
////	id a3 = [Sequence actions:a1,a2,a1,a2,a1,a2,nil];
////	[scoreLabel runAction:a3];
//
//	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
//	AtlasSprite *platform = (AtlasSprite*)[spriteManager getChildByTag:kPlatformsStartTag+5];
//	id a1 = [MoveBy actionWithDuration:2 position:ccp(100,0)];
//	id a2 = [MoveBy actionWithDuration:2 position:ccp(-200,0)];
//	id a3 = [Sequence actions:a1,a2,a1,nil];
//	id a4 = [RepeatForever actionWithAction:a3];
//	[platform runAction:a4];
//	
//	return kEventHandled;
//}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	if(gameSuspended) return;
	float accel_filter = 0.1f;
	bird_vel.x = bird_vel.x * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	NSLog(@"alertView:clickedButtonAtIndex: %i",buttonIndex);

	if(buttonIndex == 0) {
		[self startGame];
	} else {
		[self startGame];
	}
}

@end