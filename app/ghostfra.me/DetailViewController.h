//
//  DetailViewController.h
//  ghostfra.me
//
//  Created by Amit Burstein on 10/18/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailedPost.h"

@interface DetailViewController : UIViewController
@property (strong, nonatomic) DetailedPost *post;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UITableView *table;

- (void)updatePost:(DetailedPost*)post;
@end
