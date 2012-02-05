//
//  Bird.h
//  tweejump
//
//  Created by Jimmy Tang on 1/31/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bird : NSObject {
	NSString *type;
	NSString *music;
}

+ (Bird *) sharedInstance;

- (NSString*) getType;
- (void) setType:(NSString*)newVal;
- (NSString*) getMusic;
- (void) setMusic:(NSString*)newVal;

@end
