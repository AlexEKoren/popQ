//
//  FriendCell.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "FriendCell.h"
#import <UIKit/UIKit.h>

@implementation FriendCell
@synthesize table;
@synthesize person;
@synthesize addButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onAdd:(id)sender {
    self.addButton.enabled = NO;
    [table addFriend:person withCell:self];
}

- (void) changeButton {
    [self.addButton setTitle:@"Added!" forState:UIControlStateNormal];
}
@end
