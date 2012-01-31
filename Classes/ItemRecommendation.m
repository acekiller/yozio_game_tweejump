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
  MenuItem *button2 = [MenuItemImage itemFromNormalImage:@"obama.png" selectedImage:@"obama.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button3 = [MenuItemImage itemFromNormalImage:@"mittromney.png" selectedImage:@"mittromney.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button4 = [MenuItemImage itemFromNormalImage:@"cuttherope.png" selectedImage:@"cuttherope.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button5 = [MenuItemImage itemFromNormalImage:@"redbird.png" selectedImage:@"redbird.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button6 = [MenuItemImage itemFromNormalImage:@"yellowbird.png" selectedImage:@"yellowbird.png" target:self selector:@selector(button1Callback:)];
  MenuItem *button7 = [MenuItemImage itemFromNormalImage:@"pig.png" selectedImage:@"pig.png" target:self selector:@selector(button1Callback:)];
  NSLog(@"3");
	Menu *menu = [Menu menuWithItems: button1, button2, button3, button4, button5, button6, button7, nil];

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

- (void)button1Callback:(id)sender {
	NSLog(@"Romney selected");
}




@end
