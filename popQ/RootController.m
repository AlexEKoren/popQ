//
//  RootController.m
//  popQ
//
//  Created by Alex Koren on 9/23/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "RootController.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface RootController ()
@property (strong, nonatomic) IBOutlet UIImageView *redBar;
@property (strong, nonatomic) IBOutlet UIImageView *greenBar;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *onLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIView *signUpView;
@property (strong, nonatomic) IBOutlet UIView *usernameView;
@property (strong, nonatomic) IBOutlet UITextField *signUpEmailField;
@property (strong, nonatomic) IBOutlet UITextField *signUpPasswordField;
@property (strong, nonatomic) IBOutlet UITextField *signUpPhoneNumberField;
@property (strong, nonatomic) IBOutlet UITextField *makeUsernameField;
@property (strong, nonatomic) IBOutlet UIImageView *qLogo;
@property (strong, nonatomic) IBOutlet UIButton *backSignUpButton;
@property (strong, nonatomic) IBOutlet UIButton *onBackUsernameButton;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (IBAction)onFinishSignUp:(id)sender;
- (IBAction)onContinue:(id)sender;
- (IBAction)onLogin:(id)sender;
- (IBAction)onSignUp:(id)sender;
- (IBAction)onDoLogin:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onEmailChanged:(id)sender;
- (IBAction)onPasswordChanged:(id)sender;
- (IBAction)onBackSignUp:(id)sender;
- (IBAction)onBackUsername:(id)sender;
- (IBAction)onForgotPassword:(id)sender;

@end

@implementation RootController {
BOOL onHome;
BOOL segue;
BOOL alertShown;
HomeController *delegate;
NSString *resetString;
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
    [self registerForKeyboardNotifications];
    onHome = YES;
    segue = NO;
    alertShown = NO;
    resetString = @"Put your E-mail below!";
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"toHomeSegue" sender:self];
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.01];
    self.view.frame = CGRectMake(0,0,320,568);
    self.qLogo.frame = CGRectMake(60,37,200,200);
    [UIView commitAnimations];
    self.redBar.hidden = YES;
    self.greenBar.hidden = YES;
    /*self.usernameField.frame = CGRectMake(320,254,320,75);
    self.passwordField.frame = CGRectMake(320,337,320,75);
    self.onLoginButton.frame = CGRectMake(490,420,60,30);
    self.cancelButton.frame = CGRectMake(410,420,60,30);*/
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight!=568) {
        [self.backSignUpButton setCenter:CGPointMake(35,455)];
        [self.onBackUsernameButton setCenter:CGPointMake(35,455)];
    }
}


- (void) barAnimation1 {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    self.redBar.frame = CGRectMake(0,100,10,154);
    self.greenBar.frame = CGRectMake(310,154,10,100);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(barAnimation2)];
    [UIView commitAnimations];
}

- (void) barAnimation2 {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    self.redBar.frame = CGRectMake(0,130,10,124);
    self.greenBar.frame = CGRectMake(310,130,10,124);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(barAnimation3)];
    [UIView commitAnimations];
}

- (void) barAnimation3 {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    self.redBar.alpha = 0.0;
    self.greenBar.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDelegate:(HomeController *)h {
    delegate = h;
}

- (IBAction)onFinishSignUp:(id)sender {
    for (UIView *view in self.view.subviews)
        [view resignFirstResponder];
    if ([self.makeUsernameField.text length]<3) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                       message: @"That name is too short!"
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        return;
    }
    if ([self.makeUsernameField.text length]>12) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                       message: @"That name is longer than a dozen characters!"
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        return;
    }
    NSString * number = self.signUpPhoneNumberField.text;
    NSString * strippedNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options: NSRegularExpressionSearch range:NSMakeRange(0, [number length])];
    if ([self.signUpPhoneNumberField.text length] > 0) {
        if ([[strippedNumber substringToIndex:1] isEqualToString:@"1"]) {
            strippedNumber = [strippedNumber substringFromIndex:1];
        }
    }
    PFQuery *query = [PFUser query];
    [query whereKey:@"UserName" equalTo:self.makeUsernameField.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            PFUser *user = [PFUser user];
            user.username = [self.signUpEmailField.text lowercaseString];
            user.password = self.signUpPasswordField.text;
            user.email = self.signUpEmailField.text;
    
            [user setObject:strippedNumber forKey:@"PhoneNumber"];
            [user setObject:self.makeUsernameField.text forKey:@"UserName"];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:[[PFUser currentUser] objectForKey:@"UserName"] forKey:@"UserName"];
                    [currentInstallation saveInBackground];
                    [delegate finishedSignIn];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                                   message: @"Something went wrong with the sign up!"
                                                                  delegate: self
                                                         cancelButtonTitle: nil
                                                         otherButtonTitles:@"OK",nil];
                    
                    
                    [alert show];
                }
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                           message: @"That name is already taken!"
                                                          delegate: self
                                                 cancelButtonTitle: nil
                                                 otherButtonTitles:@"OK",nil];
            
            
            [alert show];
        }
    }];

}

- (IBAction)onContinue:(id)sender {
    
    onHome = NO;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:self.signUpEmailField.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                       message: @"That E-mail isn't real!"
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
    } else if ([self.signUpPasswordField.text length] < 6) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                       message: @"Password's too short!"
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
    } else {
        PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:[self.signUpEmailField.text lowercaseString]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                NSString * number = self.signUpPhoneNumberField.text;
                if ([number length] > 0) {
                    NSString * strippedNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options: NSRegularExpressionSearch range:NSMakeRange(0, [number length])];
                    if ([[strippedNumber substringToIndex:1] isEqualToString:@"1"]) {
                        strippedNumber = [strippedNumber substringFromIndex:1];
                    }
                
                    PFQuery *numberQuery = [PFUser query];
                    [numberQuery whereKey:@"PhoneNumber" equalTo:strippedNumber];
                    [numberQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (object) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                                           message: @"That phone number was already used!"
                                                                          delegate: self
                                                                 cancelButtonTitle: nil
                                                                 otherButtonTitles:@"OK",nil];
                            
                            
                            [alert show];
                        } else {
                            [UIView beginAnimations:nil context:NULL];
                            [UIView setAnimationDuration:.3];
                            self.usernameView.frame = CGRectMake(0,0,320,568);
                            [UIView commitAnimations];
                        }
                    }];
                } else {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:.3];
                    self.usernameView.frame = CGRectMake(0,0,320,568);
                    [UIView commitAnimations];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                               message: @"That E-mail was already used!"
                                                              delegate: self
                                                     cancelButtonTitle: nil
                                                     otherButtonTitles:@"OK",nil];
                
                
                [alert show];
            }
        }];
    }

}

- (IBAction)onLogin:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.loginButton.frame = CGRectMake(-320,254,320,75);
    self.signUpButton.frame = CGRectMake(-320,337,320,75);
    self.forgotPasswordButton.frame = CGRectMake(-235,410,150,30);
    self.usernameField.frame = CGRectMake(0,254,320,75);
    self.passwordField.frame = CGRectMake(0,337,320,75);
    self.onLoginButton.frame = CGRectMake(170,420,60,30);
    self.cancelButton.frame = CGRectMake(90,420,60,30);
    [UIView commitAnimations];
    
}

- (IBAction)onSignUp:(id)sender {
    onHome = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.signUpView.frame = CGRectMake(0,0,320,568);
    [UIView commitAnimations];
}

- (IBAction)onDoLogin:(id)sender {
    onHome = YES;
    /*for (UIView *view in self.view.subviews)
        [view resignFirstResponder];*/
    //[self.view resignFirstResponder];
    [PFUser logInWithUsernameInBackground:[self.usernameField.text lowercaseString] password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            segue = YES;
            self.qLogo.hidden = YES;
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation setObject:[[PFUser currentUser] objectForKey:@"UserName"] forKey:@"UserName"];
            [currentInstallation saveInBackground];
            [delegate finishedSignIn];
            //[self performSegueWithIdentifier:@"toHomeSegue" sender:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                           message: @"Wrong credentials!"
                                                          delegate: self
                                                 cancelButtonTitle: nil
                                                 otherButtonTitles:@"OK",nil];
            
            [alert show];
            self.passwordField.text = @"";
        }
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        self.loginButton.frame = CGRectMake(-320,254,320,75);
        self.signUpButton.frame = CGRectMake(-320,337,320,75);
        self.forgotPasswordButton.frame = CGRectMake(-235,410,150,30);
        self.usernameField.frame = CGRectMake(0,254,320,75);
        self.passwordField.frame = CGRectMake(0,337,320,75);
        self.onLoginButton.frame = CGRectMake(170,420,60,30);
        self.cancelButton.frame = CGRectMake(90,420,60,30);
        [UIView commitAnimations];
    }];
}

- (IBAction)onCancel:(id)sender {
    onHome = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.loginButton.frame = CGRectMake(0,254,320,75);
    self.signUpButton.frame = CGRectMake(0,337,320,75);
    self.forgotPasswordButton.frame = CGRectMake(85,410,150,30);
    self.usernameField.frame = CGRectMake(320,254,320,75);
    self.passwordField.frame = CGRectMake(320,337,320,75);
    self.onLoginButton.frame = CGRectMake(490,420,60,30);
    self.cancelButton.frame = CGRectMake(410,420,60,30);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideScreenDown)];
    [UIView commitAnimations];
}

- (void) slideScreenDown {
    for (UIView *view in self.view.subviews)
        [view resignFirstResponder];
}

- (IBAction)onEmailChanged:(id)sender {
    if ([self.usernameField.text isEqualToString:@""]) {
        [self.usernameField setFont:[UIFont systemFontOfSize:44]];
    } else {
        [self.usernameField setFont:[UIFont systemFontOfSize:30]];
    }
}

- (IBAction)onPasswordChanged:(id)sender {
    if ([self.passwordField.text isEqualToString:@""]) {
        [self.passwordField setFont:[UIFont systemFontOfSize:44]];
    } else {
        [self.passwordField setFont:[UIFont systemFontOfSize:30]];
    }
}

- (IBAction)onBackSignUp:(id)sender {
    onHome = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.signUpView.frame = CGRectMake(320,0,320,568);
    [UIView commitAnimations];
}

- (IBAction)onBackUsername:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.usernameView.frame = CGRectMake(320,0,320,568);
    [UIView commitAnimations];
}

- (IBAction)onForgotPassword:(id)sender {
    alertShown = YES;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Send yourself an e-mail!"
                                                   message: resetString
                                                  delegate: self
                                         cancelButtonTitle: @"Cancel"
                                         otherButtonTitles:@"Send!",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    resetString = @"Put your E-mail below!";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput && buttonIndex == 1) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:[[alertView textFieldAtIndex:0].text lowercaseString]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count] == 0) {
                resetString = @"Invalid E-mail!";
                [self onForgotPassword:self];
            } else {
                [PFUser requestPasswordResetForEmailInBackground:[[alertView textFieldAtIndex:0].text lowercaseString] block:^(BOOL succeeded, NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"E-mail Sent!"
                                                                   message: @"Check your E-mail for instructions!"
                                                                  delegate: self
                                                         cancelButtonTitle: nil
                                                         otherButtonTitles:@"OK",nil];
                    [alert show];
                }];
            }
        }];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIView *view in self.view.subviews) {
        for (UIView *sView in view.subviews) {
            [sView resignFirstResponder];
        }
        [view resignFirstResponder];
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (onHome && !alertShown) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        self.view.frame = CGRectMake(0,-200,320,568);
        self.qLogo.frame = CGRectMake(60,0,200,200);
        self.usernameField.frame = CGRectMake(0,254,320,75);
        self.passwordField.frame = CGRectMake(0,337,320,75);
        self.onLoginButton.frame = CGRectMake(170,420,60,30);
        self.cancelButton.frame = CGRectMake(90,420,60,30);
        [UIView commitAnimations];
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (onHome && !segue) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.view.frame = CGRectMake(0,0,320,568);
        self.qLogo.frame = CGRectMake(60,37,200,200);
        [UIView commitAnimations];
    }
    
}
@end
