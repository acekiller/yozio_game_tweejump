//
//  Bird.m
//  tweejump
//
//  Created by Jimmy Tang on 1/31/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "Bird.h"

@implementation Bird

static Bird *_sharedInstance;

- (id) init
{
	if (self = [super init])
	{
    type = @"twitter";
    music = @"bs";
	}
	return self;
}

+ (Bird *) sharedInstance
{
	if (!_sharedInstance)
	{
		_sharedInstance = [[Bird alloc] init];
	}
  
	return _sharedInstance;
}

- (NSString*) getType
{
	return type;
}

- (void) setType:(NSString*)newVal
{
	type = newVal;
}

- (NSString*) getMusic
{
	return music;
}

- (void) setMusic:(NSString*)newVal
{
	music = newVal;
}

@end
