//
//  FriendsRelationTableController.m
//  popQ
//
//  Created by Alex Koren on 9/26/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "FriendsRelationTableController.h"
#import <Parse/Parse.h>
#import "FriendCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "Person.h"

@interface FriendsRelationTableController ()

@end

@implementation FriendsRelationTableController {
PFUser *user;
NSMutableArray *contacts;
NSMutableArray *friends;
NSMutableArray *phoneNumbers;
NSMutableArray *shownContacts;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [PFUser currentUser];
    contacts = [[NSMutableArray alloc]init];
    shownContacts = [[NSMutableArray alloc]init];
    [self getAddressBook];
    phoneNumbers = [[NSMutableArray alloc]init];
    for (Person *p in contacts) {
        NSString * number = p.phoneNumber;
        NSString * strippedNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options: NSRegularExpressionSearch range:NSMakeRange(0, [number length])];
        if ([[strippedNumber substringToIndex:1] isEqualToString:@"1"]) {
            strippedNumber = [strippedNumber substringFromIndex:1];
        }
        [phoneNumbers addObject:strippedNumber];
    }
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadTable {
    [shownContacts removeAllObjects];
    PFRelation *friendRelation = [user relationforKey:@"UserFriends"];
    PFQuery *friendQuery = friendRelation.query;
    [friendQuery orderByDescending:@"UserName"];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSMutableArray *friendsPhones = [[NSMutableArray alloc]init];
            for (PFObject *object in objects) {
                Person *p = [[Person alloc]init];
                p.fullName = [object objectForKey:@"UserName"];
                p.phoneNumber = [object objectForKey:@"PhoneNumber"];
                p.isFriend = YES;
                [shownContacts addObject:p];
                [friendsPhones addObject:[object objectForKey:@"PhoneNumber"]];
            }
            PFQuery *contactQuery = [PFUser query];
            [contactQuery whereKey:@"PhoneNumber" containedIn:phoneNumbers];
            [contactQuery whereKey:@"PhoneNumber" notContainedIn:friendsPhones];
            [contactQuery whereKey:@"UserName" notEqualTo:[user objectForKey:@"UserName"]];
            [contactQuery findObjectsInBackgroundWithBlock:^(NSArray *objects2, NSError *error) {
                if (objects2) {
                    for (PFObject *object2 in objects2) {
                        Person *temp = [[Person alloc]init];
                        temp.fullName = [object2 objectForKey:@"UserName"];
                        temp.phoneNumber = [object2 objectForKey:@"PhoneNumber"];
                        temp.isFriend = NO;
                        [shownContacts addObject:temp];
                    }
                    NSArray *sortedArray;
                    sortedArray = [shownContacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                        NSString *first = [(Person*)a fullName];
                        NSString *second = [(Person*)b fullName];
                        return [first compare:second];
                    }];
                    shownContacts = [NSMutableArray arrayWithArray:sortedArray];
                    [self.tableView reloadData];
                }
            }];
        }
    }];

    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [shownContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    Person *person = (Person*)shownContacts[indexPath.row];
    if (!person.isFriend) {
        cell.nameLabel.text = ((Person*)shownContacts[indexPath.row]).fullName;
        cell.person = person;
        cell.table = self;
        cell.sendToSwitch.hidden = YES;
        cell.addButton.hidden = NO;
    } else {
        cell.nameLabel.text = ((Person*)shownContacts[indexPath.row]).fullName;
        cell.person = person;
        cell.table = self;
        cell.sendToSwitch.hidden = YES;
        cell.addButton.hidden = YES;
        cell.nameLabel.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1.0];
    }
    return cell;
}

-(void)getAddressBook {
    CFErrorRef error = NULL;
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessCompletionHandler handler = ^(bool granted, CFErrorRef error) {
        if (granted) {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressbook);
            CFIndex numPeople = ABAddressBookGetPersonCount(addressbook);
            for (int i=0; i < numPeople; i++) {
                Person *contact = [[Person alloc]init];
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                ABMutableMultiValueRef phonelist = ABRecordCopyValue(person, kABPersonPhoneProperty);
                if (!phonelist) {
                    continue;
                }
                CFTypeRef ABphone = ABMultiValueCopyValueAtIndex(phonelist, 0);
                if (!ABphone) {
                    CFRelease(phonelist);
                    continue;
                }
                NSString *personPhone = (__bridge NSString *)ABphone;
                CFRelease(phonelist);
                NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
                
                contact.fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
                contact.phoneNumber = personPhone;
                if (personPhone != NULL) {
                    [contacts addObject:contact];
                }
                CFRelease(ABphone);
            }
            CFRelease(allPeople);
        }
    };
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressbook, handler);
    } else {
        handler(false, nil);
    }
}

-(void)addedFriend:(FriendCell *)cell {
    [cell changeButton];
}

-(void)addFriend:(Person *)person withCell:(FriendCell*)cell{
    NSString * number = person.phoneNumber;
    NSString * strippedNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options: NSRegularExpressionSearch range:NSMakeRange(0, [number length])];
    if ([[strippedNumber substringToIndex:1] isEqualToString:@"1"]) {
        strippedNumber = [strippedNumber substringFromIndex:1];
    }
    if ([strippedNumber isEqualToString:[user objectForKey:@"PhoneNumber"]]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                       message: @"You can't add yourself!"
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        return;
    }
    PFQuery *phoneQuery = [PFUser query];
    [phoneQuery whereKey:@"PhoneNumber" equalTo:strippedNumber];
    [phoneQuery getFirstObjectInBackgroundWithBlock:^(PFObject *userCheck, NSError *error) {
        if (userCheck) {
            PFRelation *friendRelation = [user relationforKey:@"UserFriends"];
            PFQuery *friendQuery = friendRelation.query;
            [friendQuery whereKey:@"UserName" equalTo:[userCheck objectForKey:@"UserName"]];
            [friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject * friend, NSError *error) {
                if (friend) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                                   message: @"You're already friends with that user!"
                                                                  delegate: self
                                                         cancelButtonTitle: nil
                                                         otherButtonTitles:@"OK",nil];
                    
                    
                    [alert show];
                } else {
                    PFRelation *friendRelation = [user relationforKey:@"UserFriends"];
                    [friendRelation addObject:userCheck];
                    [self addedFriend:cell];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self reloadTable];
                    }];
                }
            }];
        } else {
        }
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
