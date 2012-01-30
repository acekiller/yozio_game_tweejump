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


@interface ItemRecommendation (Private)

@end

@implementation ItemRecommendation

- (id)init {
  
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kFPS)];
	
	[self startGame];
	
	return self;
}

@end
