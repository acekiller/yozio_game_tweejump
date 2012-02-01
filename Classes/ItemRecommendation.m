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
  [Yozio action:@"show" context:@"highscore scene" category:@"user"];
    
  if(![super init]) return nil;
  NSLog(@"2");  
  Label *title = [Label labelWithString:@"Buy Birds" fontName:@"Courier" fontSize:40];
  title.position =  ccp(100, 0);
  [self addChild: title];
  
  MenuItem *button1 = [MenuItemImage itemFromNormalImage:@"newt.png" selectedImage:@"newt.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button2 = [MenuItemImage itemFromNormalImage:@"obama.png" selectedImage:@"obama.png" target:self selector:@selector(button2Callback:)];
  MenuItem *button3 = [MenuItemImage itemFromNormalImage:@"mittromney.png" selectedImage:@"mittromney.png" target:self selector:@selector(button3Callback:)];
  MenuItem *button4 = [MenuItemImage itemFromNormalImage:@"cuttherope.png" selectedImage:@"cuttherope.png" target:self selector:@selector(button4Callback:)];
  MenuItem *button5 = [MenuItemImage itemFromNormalImage:@"redbird.png" selectedImage:@"redbird.png" target:self selector:@selector(button5Callback:)];
  MenuItem *button6 = [MenuItemImage itemFromNormalImage:@"yellowbird.png" selectedImage:@"yellowbird.png" target:self selector:@selector(button6Callback:)];
  MenuItem *button7 = [MenuItemImage itemFromNormalImage:@"pig.png" selectedImage:@"pig.png" target:self selector:@selector(button7Callback:)];
  NSLog(@"3");
  NSMutableArray *buttons = [[NSMutableArray alloc] initWithObjects:button1, button2, button3, button4, button5, button6, button7, nil];
  for(int i=0;i<10;i++){
    int a = random()%buttons.count;
    int b = random()%buttons.count;
    [buttons exchangeObjectAtIndex:a withObjectAtIndex:b];
  }
	Menu *menu = [Menu menuWithItems: [buttons objectAtIndex:0], [buttons objectAtIndex:1], [buttons objectAtIndex:2], [buttons objectAtIndex:3], [buttons objectAtIndex:4], [buttons objectAtIndex:5], [buttons objectAtIndex:6], nil];

  NSLog(@"4");
	[menu alignItemsVerticallyWithPadding:9];
//	menu.position = ccp(160,100);
	[self addChild:menu];

  NSLog(@"5");
	return self;
}

- (void)dealloc {
	NSLog(@"Highscores::dealloc");
  [Yozio action:@"exit" context:@"highscore scene" category:@"user"];
	[super dealloc];
}

- (void)updateBirdAndStartGame:(NSString*)type {
  NSLog(@"%@ selected", type);
  NSLog(@"Setting bird type from %@ to %@", [[Bird sharedInstance] getType], type);
  Bird *bird = [Bird sharedInstance];
  [bird setType:type];
	Scene *scene = [[Scene node] addChild:[Game node] z:0];
	TransitionScene *ts = [FadeTransition transitionWithDuration:0.5f scene:scene withColorRGB:0xffffff];
	[[Director sharedDirector] replaceScene:ts];
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



@end