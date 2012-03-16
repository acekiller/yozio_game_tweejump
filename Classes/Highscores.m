#import "Highscores.h"
#import "Main.h"
#import "Game.h"
#import "ItemRecommendation.h"
#import "Yozio.h"
#import "SoundEffect.h"
#import "Bird.h"
#import "AppDelegate.h"

@interface Highscores (Private)
- (void)loadCurrentPlayer;
- (void)loadHighscores;
- (void)updateHighscores;
- (void)saveCurrentPlayer;
- (void)saveHighscores;
- (void)button1Callback:(id)sender;
- (void)button2Callback:(id)sender;
- (void)button3Callback:(id)sender;
@end


@implementation Highscores

- (id)initWithScore:(int)lastScore {
	//NSLog(@"Highscores::init");
  [Yozio action:@"show"];
	
	if(![super init]) return nil;

  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
  [appDelegate->player stop];
	//NSLog(@"lastScore = %d",lastScore);
	
	currentScore = lastScore;

	//NSLog(@"currentScore = %d",currentScore);
	
	[self loadCurrentPlayer];
	[self loadHighscores];
	[self updateHighscores];
	if(currentScorePosition >= 0) {
		[self saveHighscores];
	}
	
	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
	
	AtlasSprite *title = [AtlasSprite spriteWithRect:CGRectMake(608,192,225,57) spriteManager:spriteManager];
	[spriteManager addChild:title z:5];
	title.position = ccp(160,420);

	float start_y = 360.0f;
	float step = 27.0f;
	int count = 0;
	for(NSMutableArray *highscore in highscores) {
		NSString *player = [highscore objectAtIndex:0];
		int score = [[highscore objectAtIndex:1] intValue];
		
		Label *label1 = [Label labelWithString:[NSString stringWithFormat:@"%d",(count+1)] dimensions:CGSizeMake(30,40) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:14];
		[self addChild:label1 z:5];
		[label1 setRGB:0 :0 :0];
		[label1 setOpacity:200];
		label1.position = ccp(15,start_y-count*step-2.0f);
		
		Label *label2 = [Label labelWithString:player dimensions:CGSizeMake(240,40) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:16];
		[self addChild:label2 z:5];
		[label2 setRGB:0 :0 :0];
		label2.position = ccp(160,start_y-count*step);

		Label *label3 = [Label labelWithString:[NSString stringWithFormat:@"%d",score] dimensions:CGSizeMake(290,40) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:16];
		[self addChild:label3 z:5];
		[label3 setRGB:0 :0 :0];
		[label3 setOpacity:200];
		label3.position = ccp(160,start_y-count*step);
		
		count++;
		if(count == 5) break;
	}

  NSLog(@"%@", [NSString stringWithFormat: @"%@.png", [[Bird sharedInstance] getType]]);
	MenuItem *button0 = [MenuItemImage itemFromNormalImage:[NSString stringWithFormat: @"%@.png", [[Bird sharedInstance] getType]] selectedImage:@"playAgainButton.png" target:self selector:@selector(button0Callback:)];
	MenuItem *button1 = [MenuItemImage itemFromNormalImage:@"playAgainButton.png" selectedImage:@"playAgainButton.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button3 = [MenuItemImage itemFromNormalImage:@"changePlayerButton.png" selectedImage:@"changePlayerButton.png" target:self selector:@selector(button3Callback:)];
  NSLog(@"a");

  Menu *menu = [Menu  alloc];
  NSLog(@"[Yozio stringForKey:@buyBirds defaultValue:@true] %@", [Yozio stringForKey:@"buyBirds" defaultValue:@"default"]);

  if ([[Yozio stringForKey:@"buyBirds" defaultValue:@"false"] isEqualToString:@"true"]) {
    NSLog(@"b");
    MenuItem *button2 = [MenuItemImage itemFromNormalImage:@"BuyBirds.png" selectedImage:@"BuyBirds.png" target:self selector:@selector(button2Callback:)];
    menu = [Menu menuWithItems: button0, button1, button2, button3, nil];
  } else {
    NSLog(@"c");
    menu = [Menu menuWithItems: button0, button1, button3, nil];
  }
  NSLog(@"d");


	[menu alignItemsVerticallyWithPadding:9];
	menu.position = ccp(160,100);
	
	[self addChild:menu];
  // Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
	// The "shake" nofification is posted by the PaintingWindow object when user shakes the device
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBirdView) name:@"shake" object:nil];

	return self;
}

- (void)updateBirdAndStartGame:(NSString*)type music:(NSString*)music {
  NSLog(@"%@ selected", type);
  NSLog(@"Setting bird type from %@ to %@", [[Bird sharedInstance] getType], type);
  Bird *bird = [Bird sharedInstance];
  [bird setType:type];
  [bird setMusic:music];
  NSLog(@"%@", [Scene node]);
  NSLog(@"%@", [Game node]);
  NSLog(@"%@", [Director sharedDirector]);
  NSLog(@"%@", [[Director sharedDirector] runningScene]);
  NSLog(@"%@" ,[Highscores class]);
  NSLog(@"%@", [[[Director sharedDirector] runningScene] isKindOfClass:[Highscores class]]);
  Highscores *h = [[Highscores alloc] initWithScore:currentScore];
  Scene *scene = [[Scene node] addChild:h z:0];
  [[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:1 scene:scene withColorRGB:0xffffff]];
}

// Called when receiving the "shake" notification; plays the erase sound and redraws the view
-(void) changeBirdView
{
  NSBundle *mainBundle = [NSBundle mainBundle];	
	SoundEffect *erasingSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
  NSLog(@"SHAKE");
  [erasingSound play];
  NSArray *birdTypes = [NSArray arrayWithObjects:@"pig", @"newt", @"yellowbird", @"redbird", @"cuttherope", @"obama", @"mittromney", nil];
  int i = random()%birdTypes.count;
  NSString *type = [birdTypes objectAtIndex:i];
  NSArray *birdMusics = [NSArray arrayWithObjects:@"bs", @"jb", @"rb", nil];
  int j = random()%birdMusics.count;
  NSString *music = [birdMusics objectAtIndex:j];
  NSLog(@"music seletec: %@", music);
  [self updateBirdAndStartGame:type music:music];

}



- (void)dealloc {
	NSLog(@"Highscores::dealloc");
  [Yozio action:@"exit"];
	[highscores release];
	[super dealloc];
}

- (void)loadCurrentPlayer {
	//NSLog(@"loadCurrentPlayer");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	currentPlayer = nil;
	currentPlayer = [defaults objectForKey:@"player"];
	if(!currentPlayer) {
		currentPlayer = @"anonymous";
	}

	//NSLog(@"currentPlayer = %@",currentPlayer);
}

- (void)loadHighscores {
	NSLog(@"loadHighscores");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	highscores = nil;
	highscores = [[NSMutableArray alloc] initWithArray: [defaults objectForKey:@"highscores"]];
#ifdef RESET_DEFAULTS	
	[highscores removeAllObjects];
#endif
	if([highscores count] == 0) {
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:1000000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:750000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:500000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:250000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:100000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:50000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:20000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:10000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:5000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:1000],nil]];
	}
#ifdef RESET_DEFAULTS	
	[self saveHighscores];
#endif
}

- (void)updateHighscores {
	//NSLog(@"updateHighscores");
	
	currentScorePosition = -1;
	int count = 0;
	for(NSMutableArray *highscore in highscores) {
		int score = [[highscore objectAtIndex:1] intValue];
		
		if(currentScore >= score) {
			currentScorePosition = count;
			break;
		}
		count++;
	}
	
	if(currentScorePosition >= 0) {
		[highscores insertObject:[NSArray arrayWithObjects:currentPlayer,[NSNumber numberWithInt:currentScore],nil] atIndex:currentScorePosition];
		[highscores removeLastObject];
	}
}

- (void)saveCurrentPlayer {
	//NSLog(@"saveCurrentPlayer");
	//NSLog(@"currentPlayer = %@",currentPlayer);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:currentPlayer forKey:@"player"];
}

- (void)saveHighscores {
	NSLog(@"saveHighscores");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:highscores forKey:@"highscores"];
}

- (void)button0Callback:(id)sender {
}

- (void)button1Callback:(id)sender {
	NSLog(@"play again");
  [Yozio action:@"play again"];
  
	Scene *scene = [[Scene node] addChild:[Game node] z:0];
	TransitionScene *ts = [FadeTransition transitionWithDuration:0.5f scene:scene withColorRGB:0xffffff];
	[[Director sharedDirector] replaceScene:ts];
}

- (void)button2Callback:(id)sender {
	NSLog(@"showing item recommendation screen");
	
	Scene *scene = [[Scene node] addChild:[ItemRecommendation node] z:0];
	TransitionScene *ts = [FadeTransition transitionWithDuration:0.5f scene:scene withColorRGB:0xffffff];
	[[Director sharedDirector] replaceScene:ts];
}

- (void)button3Callback:(id)sender {
	NSLog(@"update high scores");
  NSLog(@"throw an error");
  [NSException raise:@"MyException"
              format:@"Some Exceptions"];
  
	
	changePlayerAlert = [UIAlertView new];
	changePlayerAlert.title = @"Change Player";
	changePlayerAlert.message = @"\n";
	changePlayerAlert.delegate = self;
	[changePlayerAlert addButtonWithTitle:@"Save"];
	[changePlayerAlert addButtonWithTitle:@"Cancel"];

	changePlayerTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 45, 245, 27)];
	changePlayerTextField.borderStyle = UITextBorderStyleRoundedRect;
	[changePlayerAlert addSubview:changePlayerTextField];
//	changePlayerTextField.placeholder = @"Enter your name";
//	changePlayerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	changePlayerTextField.keyboardType = UIKeyboardTypeDefault;
	changePlayerTextField.returnKeyType = UIReturnKeyDone;
	changePlayerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	changePlayerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	changePlayerTextField.delegate = self;
	[changePlayerTextField becomeFirstResponder];

	[changePlayerAlert show];
}

- (void)draw {
//	NSLog(@"draw");

	if(currentScorePosition < 0) return;
	
	glColor4ub(0,0,0,50);

	float w = 320.0f;
	float h = 27.0f;
	float x = (320.0f - w)/2;
	float y = 359.0f - currentScorePosition * h;

	GLfloat vertices[4][2];	
	GLubyte indices[4] = { 0, 1, 3, 2 };
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	vertices[0][0] = x;		vertices[0][1] = y;
	vertices[1][0] = x+w;	vertices[1][1] = y;
	vertices[2][0] = x+w;	vertices[2][1] = y+h;
	vertices[3][0] = x;		vertices[3][1] = y+h;
	
	glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, indices);
	
	glDisableClientState(GL_VERTEX_ARRAY);	
}

- (void)changePlayerDone {
	currentPlayer = [changePlayerTextField.text retain];
	[self saveCurrentPlayer];
	if(currentScorePosition >= 0) {
		[highscores removeObjectAtIndex:currentScorePosition];
		[highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:0],nil]];
		[self saveHighscores];
		Highscores *h = [[Highscores alloc] initWithScore:currentScore];
		Scene *scene = [[Scene node] addChild:h z:0];
		[[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:1 scene:scene withColorRGB:0xffffff]];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//NSLog(@"alertView:clickedButtonAtIndex: %i",buttonIndex);
	
	if(buttonIndex == 0) {
		[self changePlayerDone];
	} else {
		// nothing
	}
}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	NSLog(@"textFieldShouldReturn");
//	[changePlayerAlert dismissWithClickedButtonIndex:0 animated:YES];
//	[self changePlayerDone];
//	return YES;
//}

@end
