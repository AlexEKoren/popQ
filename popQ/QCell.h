//
//  QCell.h
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface QCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet PFImageView *thumbImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *noLabel;
@property (strong, nonatomic) IBOutlet UILabel *yesLabel;
@property (strong, nonatomic) IBOutlet UILabel *noTitle;
@property (strong, nonatomic) IBOutlet UIImageView *openedImage;
@property (strong, nonatomic) IBOutlet UILabel *yesTitle;
@end
