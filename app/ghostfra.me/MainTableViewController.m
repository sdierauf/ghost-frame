//
//  MainTableViewController.m
//  ghostfra.me
//
//  Created by Amit Burstein on 10/17/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import "MainTableViewController.h"
#import "MainTableViewCell.h"
#import "MCSwipeTableViewCell.h"
#import "DetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AMScrollingNavbar/UIViewController+ScrollingNavbar.h>
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "GhostFrameAPI.h"
#import "Post.h"
#import "SCLAlertView.h"

typedef enum : NSUInteger {
    NEW_POSTS,
    HOT_POSTS,
} PostTypes;

@interface MainTableViewController () <MCSwipeTableViewCellDelegate, CLLocationManagerDelegate, DBCameraViewControllerDelegate>
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) SCLAlertView *alert;
@property BOOL DONTPOSTTWICE;
@property (strong, nonatomic) GhostFrameAPI *api;
@property (assign, nonatomic) BOOL loadingPosts;
@property (assign, nonatomic) BOOL reachedTheEnd;
@property (assign, nonatomic) PostTypes currentViewedType;
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self followScrollView:self.tableView];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    self.api = [GhostFrameAPI new];
    self.alert = [SCLAlertView new];
    self.alert.shouldDismissOnTapOutside = YES;
    
    self.tableView.tableFooterView = [self tableFooter];
    self.currentViewedType = NEW_POSTS;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showNavBarAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchPosts];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewDidAppear:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (self.currentViewedType == HOT_POSTS) {
        return;
    }
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 300;
    if(!self.reachedTheEnd && y > (h - reload_distance) && !self.loadingPosts) {
        NSLog(@"load more rows");
        [self loadOlderPosts];
    }
}

- (void)loadOlderPosts {
    Post *lastPost = [self.posts lastObject];
    [self fetchPostsWithTimestamp:lastPost.postedAt loadingNew:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (UIView *)tableFooter {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setFrame:CGRectMake(150, 15, 20, 20)];
    [indicatorView startAnimating];
    [view addSubview:indicatorView];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PhotoCell";
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    UIView *upvoteView = [self viewWithImageName:@"Upvote"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    UIView *downvoteView = [self viewWithImageName:@"Downvote"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    [cell setDefaultColor:[UIColor colorWithRed:0.827 green:0.843 blue:0.867 alpha:1] ];
    [cell setDelegate:self];
    
    Post *post = self.posts[indexPath.row];
    
    [cell setSwipeGestureWithView:downvoteView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.api downvote:post.photoUUID location: self.location callback:^(BOOL failed, NSError *error, id response) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (failed) {
                [self.alert showError:self.navigationController title:@"Could not downvote!" subTitle:@"Oh noes!" closeButtonTitle:nil duration:3.0f];
            }
        }];
    }];
    
    [cell setSwipeGestureWithView:upvoteView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.api upvote:post.photoUUID location: self.location callback:^(BOOL failed, NSError *error, id response) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (failed) {
                [self.alert showError:self.navigationController title:@"Could not upvote!" subTitle:@"Oh noes!" closeButtonTitle:nil duration:3.0f];
            }
        }];
    }];
    
    
    [cell.photoCellImage setImageWithURL:[NSURL URLWithString:post.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"DetailSegue"]) {
        
        DetailViewController *detailViewController = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];

        Post * post = (Post *) self.posts[path.row];
        [self.api fetchDetailedPost:post.photoUUID callback:^(BOOL failed, NSError * error, id response) {
            if (!failed) {
                [detailViewController updatePost:(DetailedPost*)response];
            }
        }];
    }
}

- (IBAction)switchStoryType:(UISegmentedControl*)sender {
    self.posts = @[];
    self.reachedTheEnd = NO;
    [self.tableView reloadData];
    self.currentViewedType = sender.selectedSegmentIndex;
    [self fetchPosts];
    [self.tableView setTableFooterView:NULL];
    if (self.currentViewedType == NEW_POSTS) {
        [self.tableView setTableFooterView:[self tableFooter]];
    }
}

- (IBAction)cameraButtonPressed:(id)sender {
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self openCameraWithForceQuad];
}

- (void) openCameraWithForceQuad {
    [self.locationManager startUpdatingLocation];
    
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setForceQuadCrop:YES];
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    
    [self presentViewController:nav animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (self.DONTPOSTTWICE) {
        return;
    }
    self.DONTPOSTTWICE = YES;
    //pass photo to api
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self dismissCamera:cameraViewController];
    UIImage *poop = [self imageWithImage:image convertToSize:CGSizeMake(750.0, 750.0)];
//    __unsafe_unretained typeof(self) weakSelf = self;
    if (image != nil) {
        [self.api addPostWithPhoto:poop caption:@"we 75 now" location:self.locationManager.location callback:
         ^(BOOL failed, NSError *error, id response) {
             if (error == nil) {
                 [self.alert showSuccess:self.navigationController title:@"Photo Posted!" subTitle:@"Aww yis." closeButtonTitle:nil duration:2.5f];
             } else {
                 [self.alert showError:self.navigationController title:@"Error occurred!" subTitle:@"Oh noes!" closeButtonTitle:nil duration:3.0f];
             }
             [self.navigationController popViewControllerAnimated:false]; //lol not going to get approved by apple
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             [self fetchPosts];
             self.DONTPOSTTWICE = NO;
         }];
    }
    image = nil;
    [self.locationManager stopUpdatingLocation];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


- (void) dismissCamera:(id)cameraViewController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) fetchPosts {
    if (self.currentViewedType == NEW_POSTS) {
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        [self fetchPostsWithTimestamp:milliseconds loadingNew:YES];
    } else {
        [self fetchHotPosts];
    }
}

- (void) fetchHotPosts {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.api getHotPostsAtLocation:self.locationManager.location callback:^(BOOL failed, NSError *error, NSArray *posts) {
        self.posts = posts;
        if (self.posts.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self.refreshControl endRefreshing];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        } else {
            [self.refreshControl endRefreshing];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
}

- (void) fetchPostsWithTimestamp:(long long)time loadingNew:(BOOL)refreshing {
    self.loadingPosts = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [self.api getPostsBeforeTime:time location:self.locationManager.location callback:^(BOOL failed, NSError *error, id response) {
        self.loadingPosts = NO;
        NSMutableArray *newPosts = [NSMutableArray arrayWithArray:self.posts];
        NSArray *responsePosts = (NSArray*)response;
        if (refreshing) {
            for (NSInteger i = [responsePosts count]; i > 0; i--) {
                Post *post = responsePosts[i - 1];
                if (![newPosts containsObject:post]) {
                    [newPosts insertObject:responsePosts[i - 1] atIndex:0];
                }
            }
        } else {
            if (responsePosts.count == 0) {
                self.reachedTheEnd = YES;
                [self.tableView setTableFooterView:NULL];
            }
            for (NSInteger i = 0; i < [responsePosts count]; i++) {
                Post *post = responsePosts[i];
                if (![newPosts containsObject:post]) {
                    [newPosts addObject:post];
                }
            }
        }
        self.posts = newPosts;
        if (self.posts.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (refreshing) {
                    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    [self.refreshControl endRefreshing];
                } else {
                    [self.tableView reloadData];
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        } else {
            if (refreshing) {
                [self.refreshControl endRefreshing];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
    [self.locationManager stopUpdatingLocation];
}


@end
