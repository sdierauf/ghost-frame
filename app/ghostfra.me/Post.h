//
//  Post.h
//  ghostfra.me
//
//  Created by Aengus McMillin on 10/18/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) long long postedAt;
@property (nonatomic, strong) NSString *photoUUID;
@property (nonatomic, assign) NSInteger upvotes;
@property (nonatomic, assign) NSInteger downvotes;

@end
