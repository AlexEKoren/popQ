//
//  QTableController.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "QTableController.h"
#import <Parse/Parse.h>
#import "QCell.h"
#import "QController.h"
#import <UIKit/UIKit.h>

@interface QTableController ()

@end

@implementation QTableController {
PFUser *user;
NSMutableArray *QList;
//NSMutableArray *answeredList;
//BOOL currentQAns;
PFObject *currentQ;
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
    QList = [[NSMutableArray alloc]init];
    //answeredList = [[NSMutableArray alloc]init];
    //boolList = [[NSMutableArray alloc]init];
    //[self refreshControl];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    user = [PFUser currentUser];
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
        PFQuery *QInQuery = [PFQuery queryWithClassName:@"Q"];
        [QInQuery whereKey:@"UserRecipients" equalTo:user];
        
        PFQuery *QDoneQuery = [PFQuery queryWithClassName:@"Q"];
        [QDoneQuery whereKey:@"UserAnswered" equalTo:user];
        
        /*[QDoneQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            answeredList = [NSMutableArray arrayWithArray:objects];
        }];*/
        
        PFQuery *QOutQuery = [PFQuery queryWithClassName:@"Q"];
        [QOutQuery whereKey:@"UserSender" equalTo:user];
        
        PFQuery *QQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:QInQuery,QOutQuery,QDoneQuery,nil]];
        QQuery.limit = 1000;
        if (self.pullToRefreshEnabled) {
            QQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        }
        if (self.objects.count == 0) {
            QQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        
        [QQuery orderByDescending:@"createdAt"];
        
        return QQuery;
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
    
    [QList removeAllObjects];
    for (PFObject *object in self.objects) {
        [QList addObject:object];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    
    static NSString *CellIdentifier = @"QCell";
    
    QCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    if ([[object objectForKey:@"SenderName"] isEqualToString:[user objectForKey:@"UserName"]]) {
        cell.noLabel.text = [NSString stringWithFormat:@"%d",[[object objectForKey:@"No"]intValue]];
        cell.yesLabel.text = [NSString stringWithFormat:@"%d",[[object objectForKey:@"Yes"]intValue]];
        cell.nameLabel.text = [object objectForKey:@"Question"];
        cell.dateLabel.text = [self timeDif:object.createdAt];
        //cell.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
        cell.thumbImage.file = [object objectForKey:@"Thumbnail"];
        cell.nameLabel.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1.0];
        UIFont *font = [cell.nameLabel.font fontWithSize:18.];
        cell.nameLabel.font = font;
        [cell.thumbImage loadInBackground];
        //cell.userInteractionEnabled = NO;
    } else {
        cell.nameLabel.text = [object objectForKey:@"SenderName"];
        cell.noLabel.hidden = YES;
        cell.yesLabel.hidden = YES;
        cell.yesTitle.hidden = YES;
        cell.noTitle.hidden = YES;
        cell.dateLabel.text = [self timeDif:object.createdAt];
        //cell.thumbImage.file = [object objectForKey:@"Thumbnail"];
        //[cell.thumbImage loadInBackground];
        [cell.thumbImage setContentMode:UIViewContentModeScaleAspectFit];
        if ([[object objectForKey:@"Answered"] containsObject:[user objectForKey:@"UserName"]]) {
            cell.thumbImage.image = [UIImage imageNamed:@"popcorn2 (1).png"];
        } else {
            cell.thumbImage.image = [UIImage imageNamed:@"popkernel2.png"];
        }
    }
    return cell;
}

-(NSString*)timeDif:(NSDate*)date {
    NSCalendar *Calander = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [dateFormat setDateFormat:@"dd"];
    [comps setDay:[[dateFormat stringFromDate:[NSDate date]] intValue]];
    [dateFormat setDateFormat:@"MM"];
    [comps setMonth:[[dateFormat stringFromDate:[NSDate date]] intValue]];
    [dateFormat setDateFormat:@"yyyy"];
    [comps setYear:[[dateFormat stringFromDate:[NSDate date]] intValue]];
    [dateFormat setDateFormat:@"HH"];
    [comps setHour:[[dateFormat stringFromDate:[NSDate date]] intValue]];
    [dateFormat setDateFormat:@"mm"];
    [comps setMinute:[[dateFormat stringFromDate:[NSDate date]] intValue]];
    
    NSDate *currentDate=[Calander dateFromComponents:comps];
    
    //NSLog(@"Current Date is :- '%@'",currentDate);
    
    
    [dateFormat setDateFormat:@"dd"];
    [comps setDay:[[dateFormat stringFromDate:date] intValue]];
    [dateFormat setDateFormat:@"MM"];
    [comps setMonth:[[dateFormat stringFromDate:date] intValue]];
    [dateFormat setDateFormat:@"yyyy"];
    [comps setYear:[[dateFormat stringFromDate:date] intValue]];
    [dateFormat setDateFormat:@"HH"];
    [comps setHour:[[dateFormat stringFromDate:date] intValue]];
    [dateFormat setDateFormat:@"mm"];
    [comps setMinute:[[dateFormat stringFromDate:date] intValue]];
    
    NSDate *reminderDate=[Calander dateFromComponents:comps];
    
    //NSLog(@"Current Date is :- '%@'",reminderDate);
    
    //NSLog(@"Current Date is :- '%@'",currentDate);
    
    NSTimeInterval ti = [reminderDate timeIntervalSinceDate:currentDate];
    
    //NSLog(@"Time Interval is :- '%f'",ti);
    int days = abs(ti/86400);
    if (days == 0) {
        [dateFormat setDateFormat:@"HH:mm"];
        NSString *d = [dateFormat stringFromDate:date];
        d = [NSString stringWithFormat:@"%@ %@",@"Today at",d];
        return d;
    } else if (days == 1) {
        [dateFormat setDateFormat:@"HH:mm"];
        NSString *d = [dateFormat stringFromDate:date];
        d = [NSString stringWithFormat:@"%@ %@",@"Yesterday at",d];
        return d;
    } else if (days < 7) {
        return [NSString stringWithFormat:@"%d days ago",days];
    } else  if (days < 14) {
        return @"1 week ago";
    } else {
        return [NSString stringWithFormat:@"%d weeks ago",days/7];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentQ = QList[indexPath.row];
    [self performSegueWithIdentifier:@"toQSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toQSegue"]) {
        QController *destViewController = segue.destinationViewController;
        destViewController.q = currentQ;
    }
}

@end
