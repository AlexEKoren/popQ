//
//  FriendsTableController.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "FriendsTableController.h"
#import <Parse/Parse.h>
#import "FriendCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Person.h"
#import <UIKit/UIKit.h>

@interface FriendsTableController ()

@end

@implementation FriendsTableController {
    PFUser *user;
    NSMutableArray *friendList;
    NSMutableArray *contactData;
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
    contactData = [[NSMutableArray alloc]init];
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
    cell.sendToSwitch.hidden = YES;
    return cell;
}

-(void)getAddressBook {
    CFErrorRef error = NULL;
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessCompletionHandler handler = ^(bool granted, CFErrorRef error) {
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressbook);
        CFIndex numPeople = ABAddressBookGetPersonCount(addressbook);
        for (int i=0; i < numPeople; i++) {
            Person *contact = [[Person alloc]init];
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            ABMutableMultiValueRef phonelist = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFTypeRef ABphone = ABMultiValueCopyValueAtIndex(phonelist, 0);
            if (!ABphone) {
                continue;
            }
            NSString *personPhone = (__bridge NSString *)ABphone;
            contact.phoneNumber = personPhone;
            CFRelease(ABphone);
            CFRelease(phonelist);
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            contact.fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
            [contactData addObject:contact];
        }
        CFRelease(allPeople);
    };
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressbook, handler);
    } else {
        handler(false, nil);
    }
    NSArray *sortedArray;
    sortedArray = [contactData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Person*)a fullName];
        NSString *second = [(Person*)b fullName];
        return [first compare:second];
    }];
    contactData = [NSMutableArray arrayWithArray:sortedArray];
}
@end
