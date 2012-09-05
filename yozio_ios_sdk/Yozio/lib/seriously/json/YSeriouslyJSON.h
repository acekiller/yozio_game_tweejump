//
//  SeriouslyJSON.h
//  Test
//
//  Created by Corey Johnson on 6/25/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#if !defined(__YSeriouslyJSON__)
#define __YSeriouslyJSON__ 1


#import <Foundation/Foundation.h>


@interface YSeriouslyJSON : NSObject {
    id _currentObject;
    NSMutableArray *_stack;
    NSMutableArray *_keys;
}

+ (id)parse:(NSString *)string;

@end

#endif /* ! __YSeriouslyJSON__ */
