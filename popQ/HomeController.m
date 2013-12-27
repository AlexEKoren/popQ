//
//  HomeController.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "HomeController.h"
#import <Parse/Parse.h>
#import "RootController.h"
#import "QTableController.h"
#import <UIKit/UIKit.h>
@interface HomeController ()
- (IBAction)onFriends:(id)sender;
- (IBAction)onCamera:(id)sender;
- (IBAction)onLogout:(id)sender;


@end

@implementation HomeController {
QTableController *feedTable;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    if (![PFUser currentUser]) { // No user logged in
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        RootController *logInViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootController"];
        [logInViewController setDelegate:self];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:^(void){}];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [feedTable queryForTable];
    [feedTable loadObjects];
    [feedTable refreshControl];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishedSignIn{
    [feedTable queryForTable];
    [feedTable loadObjects];
    [feedTable refreshControl];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction)onFriends:(id)sender {
    [self performSegueWithIdentifier:@"toFriendsSegue" sender:self];
}

- (IBAction)onCamera:(id)sender {
    [self performSegueWithIdentifier:@"toMakeQSegue" sender:self];
}

- (IBAction)onLogout:(id)sender {
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    RootController *logInViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootController"];
    [logInViewController setDelegate:self];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"feedEmbed"]) {
        feedTable = (QTableController*) [segue destinationViewController];
    }
}
@end
