//
//  FriendCell.h
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Person.h"
#import "FriendsRelationTableController.h"
@class FriendsRelationTableController;
@interface FriendCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UISwitch *sendToSwitch;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) FriendsRelationTableController *table;
- (void)changeButton;
- (IBAction)onAdd:(id)sender;

@end
