//
//  ChooseFriendsTableController.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "ChooseFriendsTableController.h"
#import <Parse/Parse.h>
#import "FriendCell.h"
#import <UIKit/UIKit.h>
@interface ChooseFriendsTableController ()

@end

@implementation ChooseFriendsTableController {
PFUser *user;
NSMutableArray *friendList, *friendCells;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pullToRefreshEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [PFUser currentUser];
    friendList = [[NSMutableArray alloc]init];
    friendCells = [[NSMutableArray alloc]init];
    //[self refreshControl];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [self queryForTable];
    [self loadObjects];
    [self refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (PFQuery*)queryForTable {
    if (user) {
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"@\"%@\" IN Students",user.email]];
        PFRelation *friendRelation = [user relationforKey:@"UserFriends"];
        PFQuery *friendQuery = friendRelation.query;
        
        if (self.pullToRefreshEnabled) {
            friendQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        }
        if (self.objects.count == 0) {
            friendQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        
        [friendQuery orderByDescending:@"UserName"];
        
        return friendQuery;
    }
    return NULL;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    
    [friendList removeAllObjects];
    [friendCells removeAllObjects];
    for (PFObject *object in self.objects) {
        [friendList addObject:object];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    
    static NSString *CellIdentifier = @"FriendCell";
    
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.nameLabel.text = [object objectForKey:@"UserName"];
    cell.addButton.hidden = YES;
    cell.user = (PFUser *) object;
    [friendCells addObject:cell];
    return cell;
}

- (NSMutableArray*)getCells {
    return friendCells;
}

@end
