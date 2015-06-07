//
//  Post.m
//  ghostfra.me
//
//  Created by Aengus McMillin on 10/18/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import "Post.h"

@implementation Post

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[Post class]]) {
        return NO;
    } else {
        return [((Post*)object).photoURL isEqualToString:self.photoURL];
    }
    
}
@end
