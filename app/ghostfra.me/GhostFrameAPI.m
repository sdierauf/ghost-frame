//
//  GhostFrameAPI.m
//  ghostfra.me
//
//  Created by Aengus McMillin on 10/17/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import "GhostFrameAPI.h"
#import <AFNetworking/AFNetworking.h>
#import "Post.h"
#import "DetailedPost.h"

@implementation GhostFrameAPI

- (id)init {
    return [self initWithKey:@""];
}

- (id)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        self.key = key;
    }
    return self;
}

- (NSString*)urlWithEndpoint:(NSString*)endpoint {
    
    return [NSString stringWithFormat:@"http://v1.api.ghostfra.me%@", endpoint];
    //return [NSString stringWithFormat:@"http://69.91.179.89%@", endpoint];
    
}

- (void)addPostWithPhoto:(UIImage *)image caption:(NSString *)caption location:(CLLocation*)location callback:(Callback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
    
    NSDictionary *params = @{
                             @"user_id": currentDeviceId,
                             @"latitude": @(location.coordinate.latitude),
                             @"longitude": @(location.coordinate.longitude),
                             @"caption": caption,
                             @"photo": [UIImageJPEGRepresentation(image, 0.60) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],
                             @"key": self.key
                             };
    
    [manager POST:[self urlWithEndpoint:@"/post/new"]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              callback(NO, NULL, responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              callback(YES, error, NULL);
          }];
}

- (void)getPostsWithParams:(NSDictionary*)params url:(NSString*)url callback:(GetPostsCallback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%@", responseObject);
              NSArray *posts = responseObject[@"posts"];
              NSMutableArray *postObjects = [NSMutableArray array];
              for (NSDictionary *post in posts) {
                  Post *newPost = [[Post alloc] init];
                  newPost.photoURL = post[@"photo_share_url"];
                  newPost.latitude = [post[@"latitude"] doubleValue];
                  newPost.longitude = [post[@"longitude"] doubleValue];
                  newPost.postedAt = [post[@"posted_at"] longLongValue];
                  newPost.caption = post[@"caption"];
                  newPost.photoUUID = post[@"photo"];
                  newPost.upvotes = [post[@"upvotes"] intValue];
                  newPost.downvotes = [post[@"downvotes"] intValue];
                  [postObjects addObject:newPost];
              }
              NSLog(@"JSON: %@", responseObject);
              callback(NO, NULL, postObjects);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              callback(YES, error, NULL);
          }];
}

- (void)getPostsBeforeTime:(long long)time location:(CLLocation*)location callback:(GetPostsCallback)callback {
    NSDictionary *params = @{
                             @"last_post_time": @(time),
                             @"latitude": @(location.coordinate.latitude),
                             @"longitude": @(location.coordinate.longitude),
                             @"key": self.key
                             };
    
    [self getPostsWithParams:params url:[self urlWithEndpoint:@"/post/view"] callback:callback];
}

- (void)getHotPostsAtLocation:(CLLocation *)location callback:(GetPostsCallback)callback {
    NSDictionary *params = @{
                             @"latitude": @(location.coordinate.latitude),
                             @"longitude": @(location.coordinate.longitude),
                             @"key": self.key
                             };
    
    [self getPostsWithParams:params url:[self urlWithEndpoint:@"/post/hot"] callback:callback];
}

- (void)upvote:(NSString *)pictureUUID location:(CLLocation *)location callback:(Callback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{
                             @"photo": pictureUUID,
                             @"latitude": @(location.coordinate.latitude),
                             @"longitude": @(location.coordinate.longitude),
                             @"key": self.key
                             };
    [manager POST:[self urlWithEndpoint:@"/post/upvote"]
       parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           callback(NO, NULL, NULL);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Error: %@", error);
           callback(YES, error, NULL);
       }];
}

- (void)downvote:(NSString *)pictureUUID location:(CLLocation *)location callback:(Callback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{
                             @"photo": pictureUUID,
                             @"latitude": @(location.coordinate.latitude),
                             @"longitude": @(location.coordinate.longitude),
                             @"key": self.key
                             };
    [manager POST:[self urlWithEndpoint:@"/post/downvote"]
       parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           callback(NO, NULL, NULL);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Error: %@", error);
           callback(YES, error, NULL);
       }];
}

- (void)fetchDetailedPost:(NSString *)pictureUUID callback:(Callback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{
                             @"photo": pictureUUID
                             };
    [manager POST:[self urlWithEndpoint:@"/post/detailed"]
       parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           NSDictionary *post = responseObject;
           
               DetailedPost *newPost = [[DetailedPost alloc] init];
               newPost.photoURL = post[@"photo_share_url"];
               newPost.latitude = [post[@"latitude"] doubleValue];
               newPost.longitude = [post[@"longitude"] doubleValue];
               newPost.postedAt = [post[@"posted_at"] longLongValue];
               newPost.caption = post[@"caption"];
               newPost.photoUUID = post[@"photo"];
               newPost.upvotes = [post[@"upvotes"] intValue];
               newPost.downvotes = [post[@"downvotes"] intValue];
               newPost.commentContent = post[@"comment_content"];
           
           NSLog(@"JSON: %@", responseObject);
           callback(NO, NULL, newPost);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Error: %@", error);
           callback(YES, error, NULL);
       }];
}

- (void)addComment:(NSString *)pictureUUID location:(CLLocation *)location content:(NSString *)content callback:(Callback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
    NSDictionary *params = @{
                              @"user_id": currentDeviceId,
                              @"photo": pictureUUID,
                              @"latitude": @(location.coordinate.latitude),
                              @"longitude": @(location.coordinate.longitude),
                              @"content": content,
                              };
    [manager POST:[self urlWithEndpoint:@"/post/comment"]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              callback(NO, NULL, responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              callback(YES, error, NULL);
          }];
}

- (void)upvoteComment:(NSString*)commentId forPicture:(NSString*)pictureUUID location:(CLLocation*)location callback:(Callback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{
                              @"photo": pictureUUID,
                              @"comment_id": commentId,
                              @"latitude": @(location.coordinate.latitude),
                              @"longitude": @(location.coordinate.longitude),
                              };
    [manager POST:[self urlWithEndpoint:@"/post/comment/upvote"]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              callback(NO, NULL, responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              callback(YES, error, NULL);
          }];
}

- (void)downvoteComment:(NSString*)commentId forPicture:(NSString*)pictureUUID location:(CLLocation*)location callback:(Callback)callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{
                              @"photo": pictureUUID,
                              @"comment_id": commentId,
                              @"latitude": @(location.coordinate.latitude),
                              @"longitude": @(location.coordinate.longitude),
                              };
    [manager POST:[self urlWithEndpoint:@"/post/comment/downvote"]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              callback(NO, NULL, responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              callback(YES, error, NULL);
          }];
}


@end
