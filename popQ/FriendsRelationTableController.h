//
//  FriendsRelationTableController.h
//  popQ
//
//  Created by Alex Koren on 9/26/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "FriendCell.h"
@class FriendCell;
@interface FriendsRelationTableController : UITableViewController
-(void)addFriend:(Person*)p withCell:(FriendCell*)cell;
-(void)reloadTable;
@end
