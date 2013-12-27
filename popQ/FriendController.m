//
//  FriendController.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "FriendController.h"
#import <Parse/Parse.h>
#import "FriendsRelationTableController.h"
#import <UIKit/UIKit.h>

@interface FriendController ()
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIView *friendContainer;
@property (strong, nonatomic) IBOutlet UIButton *addFriendButton;
- (IBAction)onAdd:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation FriendController {
PFUser *user;
FriendsRelationTableController *friendsTable;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	user = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAdd:(id)sender {
    self.addFriendButton.enabled = NO;
    if ([self.searchField.text isEqualToString:[user objectForKey:@"UserName"]]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                       message: @"You can't add yourself!"
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        self.addFriendButton.enabled = YES;
        return;
    }
    PFQuery *query = [PFUser query];
    [query whereKey:@"UserName" equalTo:self.searchField.text];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *user2, NSError *error) {
        if (!user2) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                           message: @"That user doesn't exist!"
                                                          delegate: self
                                                 cancelButtonTitle: nil
                                                 otherButtonTitles:@"OK",nil];
            
            
            [alert show];
            self.addFriendButton.enabled = YES;
        } else {
            PFRelation *friendRelation = [user relationforKey:@"UserFriends"];
            PFQuery *friendQuery = friendRelation.query;
            [friendQuery whereKey:@"UserName" equalTo:self.searchField.text];
            [friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject * friend, NSError *error) {
                if (friend) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                                   message: @"You're already friends with that user!"
                                                                  delegate: self
                                                         cancelButtonTitle: nil
                                                         otherButtonTitles:@"OK",nil];
                    
                    
                    [alert show];
                    self.addFriendButton.enabled = YES;
                } else {
                    PFRelation *friendRelation = [user relationforKey:@"UserFriends"];
                    [friendRelation addObject:user2];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Yay!"
                                                                       message: [NSString stringWithFormat:@"You've just added %@ as a friend!",[user2 objectForKey:@"UserName"]]
                                                                      delegate: self
                                                             cancelButtonTitle: nil
                                                             otherButtonTitles:@"OK",nil];
                        
                        
                        [alert show];
                        self.addFriendButton.enabled = YES;
                        [friendsTable reloadTable];
                        self.searchField.text = @"";
                    }];
                    
                }
            }];
        }
    }];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"friendsListEmbed"]) {
        friendsTable = (FriendsRelationTableController *) [segue destinationViewController];
    }
}

- (IBAction)onBack:(id)sender {
    [self performSegueWithIdentifier:@"backToHomeSegue" sender:self];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIView *view in self.view.subviews) {
        for (UIView *sView in view.subviews) {
            [sView resignFirstResponder];
        }
        [view resignFirstResponder];
    }
}
@end
