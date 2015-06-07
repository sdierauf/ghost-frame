//
//  CommentTableViewCell.h
//  ghostfra.me
//
//  Created by Stefan Dierauf on 10/18/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@interface CommentTableViewCell : MCSwipeTableViewCell

@property (nonatomic, strong) NSString * comment;
@property (nonatomic) NSInteger * upvotes;
@property (nonatomic) NSInteger * downvotes;

@end
