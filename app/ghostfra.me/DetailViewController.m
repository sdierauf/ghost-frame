//
//  DetailViewController.m
//  ghostfra.me
//
//  Created by Amit Burstein on 10/18/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import "DetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SCLAlertView.h"
#import "CommentTableViewCell.h"
#import "GhostFrameAPI.h"

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource, MCSwipeTableViewCellDelegate>
@property (strong, nonatomic) SCLAlertView *addCommentView;
@property (strong, nonatomic) GhostFrameAPI *api;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) SCLAlertView *alert;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.photoView setImageWithURL: [NSURL URLWithString:self.post.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", self.post.upvotes - self.post.downvotes];
    self.addCommentView = [SCLAlertView new];
    self.addCommentView.shouldDismissOnTapOutside = YES;
    self.api = [GhostFrameAPI new];
    self.locationManager = [CLLocationManager new];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.alert = [SCLAlertView new];
    self.alert.shouldDismissOnTapOutside = YES;
}

- (void)updatePost:(DetailedPost*)post {
    self.post = post;
    [self.photoView setImageWithURL:[NSURL URLWithString:self.post.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", self.post.upvotes - self.post.downvotes];
    [self.table reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (IBAction)addComment:(id)sender {
    UITextField *textField = [self.addCommentView addTextField:nil];
    NSString *photoID = self.post.photoUUID;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [self.locationManager startUpdatingLocation];
    [self.addCommentView addButton:@"Post" actionBlock:^{
        [self.api addComment:photoID location:self.locationManager.location content:textField.text callback:^(BOOL failed, NSError *error, id response) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.api fetchDetailedPost:self.post.photoUUID callback:^(BOOL failed, NSError * error, id response) {
                if (!failed) {
                    [self updatePost:(DetailedPost*)response];
                }
            }];

            if (failed) {
                [self.alert showError:self.navigationController title:@"Could not add comment!" subTitle:@"Oh noes!" closeButtonTitle:nil duration:3.0f];
            }
        }];
        NSLog(@"Text value: %@", textField.text);
    }];
    [self.locationManager stopUpdatingLocation];
    [self.addCommentView showEdit:self.navigationController title:@"Leave a comment!" subTitle:@"Be nice..." closeButtonTitle:nil duration:0.0f];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CommentCell";
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if (!cell) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    
    [self.locationManager startUpdatingLocation];
    
    [cell setSwipeGestureWithView:downvoteView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.api downvoteComment:self.post.commentContent[indexPath.row][@"comment_id"] forPicture:self.post.photoUUID location:[self.locationManager location] callback:^(BOOL failed, NSError *error, id response) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (failed) {
                [self.alert showError:self.navigationController title:@"Could not downvote!" subTitle:@"Oh noes!" closeButtonTitle:nil duration:3.0f];
            }
        }];
    }];
    
    [cell setSwipeGestureWithView:upvoteView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.api upvoteComment:self.post.commentContent[indexPath.row][@"comment_id"] forPicture:self.post.photoUUID location:[self.locationManager location] callback:^(BOOL failed, NSError *error, id response) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (failed) {
                [self.alert showError:self.navigationController title:@"Could not upvote!" subTitle:@"Oh noes!" closeButtonTitle:nil duration:3.0f];
            }
        }];
    }];
    
    [self.locationManager stopUpdatingLocation];
    cell.textLabel.text = self.post.commentContent[indexPath.row][@"content"];
    
    return cell;
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.post.commentContent.count;
}

@end
