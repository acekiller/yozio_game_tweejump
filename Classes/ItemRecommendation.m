//
//  ItemRecommendation.m
//  tweejump
//
//  Created by Jimmy Tang on 1/29/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "ItemRecommendation.h"
#import "Main.h"
#import "Highscores.h"
#import "Yozio.h"
#import "Game.h"
#import "Bird.h"

@interface ItemRecommendation (Private)

- (void)button1Callback:(id)sender;
- (void)button2Callback:(id)sender;
- (void)button3Callback:(id)sender;

@end

@implementation ItemRecommendation

- (id)init {
  //NSLog(@"Highscores::init");
  NSLog(@"1");
  [Yozio action:@"show ItemRecommendation" category:@"user"];
    
  if(![super init]) return nil;
  NSLog(@"2");  
  Label *title = [Label labelWithString:@"Buy Birds" fontName:@"Courier" fontSize:40];
  title.position =  ccp(100, 0);
  [self addChild: title];
  
  MenuItem *button1 = [MenuItemImage itemFromNormalImage:@"newt-menu.png" selectedImage:@"newt-menu.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button2 = [MenuItemImage itemFromNormalImage:@"obama-menu.png" selectedImage:@"obama-menu.png" target:self selector:@selector(button2Callback:)];
  MenuItem *button3 = [MenuItemImage itemFromNormalImage:@"mittromney-menu.png" selectedImage:@"mittromney-menu.png" target:self selector:@selector(button3Callback:)];
  MenuItem *button4 = [MenuItemImage itemFromNormalImage:@"cuttherope-menu.png" selectedImage:@"cuttherope-menu.png" target:self selector:@selector(button4Callback:)];
  MenuItem *button5 = [MenuItemImage itemFromNormalImage:@"redbird-menu.png" selectedImage:@"redbird-menu.png" target:self selector:@selector(button5Callback:)];
  MenuItem *button6 = [MenuItemImage itemFromNormalImage:@"yellowbird-menu.png" selectedImage:@"yellowbird-menu.png" target:self selector:@selector(button6Callback:)];
  MenuItem *button7 = [MenuItemImage itemFromNormalImage:@"pig-menu.png" selectedImage:@"pig-menu.png" target:self selector:@selector(button7Callback:)];
  NSLog(@"3");
  NSMutableArray *buttons = [NSMutableArray alloc];
  NSString *recommendationOrder = [Yozio stringForKey:@"recommendationOrder" defaultValue:@"cartoonsFirst"];
  if ([recommendationOrder isEqualToString:@"politiciansFirst"]) {
    buttons = [[NSMutableArray alloc] initWithObjects:button1, button2, button3, nil];
  } else if ([recommendationOrder isEqualToString:@"cartoonsFirst"]) {
    buttons = [[NSMutableArray alloc] initWithObjects:button4, button5, button6, nil];
  } else {
    buttons = [[NSMutableArray alloc] initWithObjects:button1, button2, button5, nil];
    for(int i=0;i<10;i++){
      int a = random()%buttons.count;
      int b = random()%buttons.count;
      [buttons exchangeObjectAtIndex:a withObjectAtIndex:b];
    }

  }
  MenuItem *backButton = [MenuItemImage itemFromNormalImage:@"backButton.png" selectedImage:@"backButton.png" target:self selector:@selector(backButtonCallback:)];
	Menu *menu = [Menu menuWithItems: [buttons objectAtIndex:0], [buttons objectAtIndex:1], [buttons objectAtIndex:2], backButton, nil];

  NSLog(@"4");
	[menu alignItemsVerticallyWithPadding:9];
//	menu.position = ccp(160,100);
	[self addChild:menu];

  NSLog(@"5");
	return self;
}

- (void)dealloc {
	NSLog(@"Highscores::dealloc");
  [Yozio action:@"exit ItemRecommendation" category:@"user"];
	[super dealloc];
}

- (void)updateBirdAndStartGame:(NSString*)type {
  NSLog(@"%@ selected", type);
  NSLog(@"Setting bird type from %@ to %@", [[Bird sharedInstance] getType], type);
  Bird *bird = [Bird sharedInstance];
  [bird setType:type];
  Highscores *h = [[Highscores alloc] initWithScore:0];
  Scene *scene = [[Scene node] addChild:h z:0];
  [[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:1 scene:scene withColorRGB:0xffffff]];
}

- (void)button1Callback:(id)sender {
  NSString *type = @"newt";
  [self updateBirdAndStartGame:type];
}
- (void)button2Callback:(id)sender {
  NSString *type = @"obama";
  [self updateBirdAndStartGame:type];
}
- (void)button3Callback:(id)sender {
  NSString *type = @"mittromney";
  [self updateBirdAndStartGame:type];
}
- (void)button4Callback:(id)sender {
  NSString *type = @"cuttherope";
  [self updateBirdAndStartGame:type];
}
- (void)button5Callback:(id)sender {
  NSString *type = @"redbird";
  [self updateBirdAndStartGame:type];
}
- (void)button6Callback:(id)sender {
  NSString *type = @"yellowbird";
  [self updateBirdAndStartGame:type];
}
- (void)button7Callback:(id)sender {
  NSString *type = @"pig";
  [self updateBirdAndStartGame:type];
}
- (void)backButtonCallback:(id)sender {
  Highscores *h = [[Highscores alloc] initWithScore:0];
  Scene *scene = [[Scene node] addChild:h z:0];
  [[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:1 scene:scene withColorRGB:0xffffff]];
}



@end
