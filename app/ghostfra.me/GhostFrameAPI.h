//
//  GhostFrameAPI.h
//  ghostfra.me
//
//  Created by Aengus McMillin on 10/17/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^Callback)(BOOL failed, NSError *error, id response);
typedef void(^GetPostsCallback)(BOOL failed, NSError *error, NSArray *posts);

@interface GhostFrameAPI : NSObject
@property (nonatomic, strong) NSString *key;

- (id)initWithKey:(NSString*)key;
- (void)addPostWithPhoto:(UIImage*)image caption:(NSString*)caption location:(CLLocation*)location callback:(Callback)callback;
- (void)getPostsBeforeTime:(long long)time location:(CLLocation*)location callback:(GetPostsCallback)callback;
- (void)getHotPostsAtLocation:(CLLocation*)location callback:(GetPostsCallback)callback;
- (void)upvote:(NSString *)pictureUUID location:(CLLocation *)location callback:(Callback)callback;
- (void)downvote:(NSString *)pictureUUID location:(CLLocation *)location callback:(Callback)callback;
- (void)fetchDetailedPost:(NSString *)pictureUUID callback:(Callback)callback;
- (void)addComment:(NSString *)pictureUUID location:(CLLocation *)location content:(NSString *)content callback:(Callback)callback;
- (void)upvoteComment:(NSString*)commentId forPicture:(NSString*)pictureUUID location:(CLLocation*)location callback:(Callback)callback;
- (void)downvoteComment:(NSString*)commentId forPicture:(NSString*)pictureUUID location:(CLLocation*)location callback:(Callback)callback;
@end
