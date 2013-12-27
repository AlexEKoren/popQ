//
//  QController.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "QController.h"
#import <UIKit/UIKit.h>

@interface QController ()
@property (strong, nonatomic) IBOutlet UIImageView *questionImage;
@property (strong, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutlet UIButton *xButton;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet UIImageView *noBar;
@property (strong, nonatomic) IBOutlet UIImageView *yesBar;
- (IBAction)onYes:(id)sender;
- (IBAction)onNo:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation QController {
PFUser *user;
int height;
int length;
}
@synthesize q;
@synthesize answered;
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
    [[q objectForKey:@"Picture"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.questionImage.image = [UIImage imageWithData:data];
            self.questionLabel.text = [q objectForKey:@"Question"];

        } else {
            NSLog(@"error");
        }
    }];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    height = (int)screenRect.size.height;
    length = height - 80;
    user = [PFUser currentUser];
    self.checkButton.hidden = YES;
    self.xButton.hidden = YES;
    self.checkButton.alpha = 0.0;
    self.xButton.alpha = 0.0;
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[q objectForKey:@"SenderName"] isEqualToString:[user objectForKey:@"UserName"]]) {
        if (![[q objectForKey:@"Answered"] containsObject:[user objectForKey:@"UserName"]]) {
            self.xButton.hidden = NO;
            self.checkButton.hidden = NO;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0];
            self.xButton.alpha = 1.0;
            self.checkButton.alpha = 1.0;
            [UIView commitAnimations];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[q objectForKey:@"SenderName"] isEqualToString:[user objectForKey:@"UserName"]] || [[q objectForKey:@"Answered"] containsObject:[user objectForKey:@"UserName"]]) {
        [self performSelector:@selector(showBars) withObject:nil afterDelay:0.1f];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onYes:(id)sender {
    [q incrementKey:@"Yes"];
    PFRelation *recipientsRelation = [q relationforKey:@"UserRecipients"];
    [recipientsRelation removeObject:user];
    PFRelation *answeredRelation = [q relationforKey:@"UserAnswered"];
    [answeredRelation addObject:user];
    NSMutableArray *ans = [q objectForKey:@"Answered"];
    if (!ans) {
        ans = [[NSMutableArray alloc]init];
    }
    [ans addObject:[user objectForKey:@"UserName"]];
    [q setObject:ans forKey:@"Answered"];
    [q saveInBackground];
    self.xButton.enabled = NO;
    self.checkButton.enabled = NO;
    [self showBars];
}

- (IBAction)onNo:(id)sender {
    [q incrementKey:@"No"];
    PFRelation *recipientsRelation = [q relationforKey:@"UserRecipients"];
    [recipientsRelation removeObject:user];
    PFRelation *answeredRelation = [q relationforKey:@"UserAnswered"];
    [answeredRelation addObject:user];
    NSMutableArray *ans = [q objectForKey:@"Answered"];
    if (!ans) {
        ans = [[NSMutableArray alloc]init];
    }
    [ans addObject:[user objectForKey:@"UserName"]];
    [q setObject:ans forKey:@"Answered"];
    [q saveInBackground];
    self.xButton.enabled = NO;
    self.checkButton.enabled = NO;
    [self showBars];
}

- (void)showBars {
    
    self.yesBar.hidden = NO;
    self.noBar.hidden = NO;
    int yes = [[q objectForKey:@"Yes"] intValue];
    int no = [[q objectForKey:@"No"] intValue];
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:1.0];
    if (no>0) {
        self.noBar.frame = CGRectMake(0, height-(no*1.0*length/(no+yes)), 10, (no*1.0*length/(no+yes)));
    }
    if (yes>0) {
        self.yesBar.frame = CGRectMake(310, height-(yes*1.0*length/(no+yes)), 10, (yes*1.0*length/(no+yes)));
    }
    self.xButton.alpha = 0.0;
    self.checkButton.alpha = 0.0;
    [UIView commitAnimations];
}

- (IBAction)onBack:(id)sender {
    [self performSegueWithIdentifier:@"backToFeedSegue" sender:self];
}
@end
