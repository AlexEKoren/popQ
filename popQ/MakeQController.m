//
//  MakeQController.m
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "MakeQController.h"
#import <UIKit/UIKit.h>
#import "ChooseFriendsTableController.h"
#import "FriendCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import "RootController.h"
@interface MakeQController ()
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) IBOutlet UITextField *questionField;
@property (strong, nonatomic) IBOutlet UIButton *redoButton;
@property (strong, nonatomic) IBOutlet UIButton *flipButton;
- (IBAction)onRedo:(id)sender;
- (IBAction)onFlip:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *submitView;
@property (strong, nonatomic) IBOutlet UIView *friendsContainer;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) IBOutlet UIImageView *previewImage;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
- (IBAction)onBack:(id)sender;
- (IBAction)onSubmit:(id)sender;
- (IBAction)onCamera:(id)sender;
- (IBAction)onQuestionEdit:(id)sender;

@end

@implementation MakeQController {
ChooseFriendsTableController *friendsTable;
PFUser *user;
UIImagePickerController *picker;
BOOL picCaptured;
BOOL questionTyped;
AVCaptureSession *session;
AVCaptureOutput *output;
AVCaptureConnection *videoConnection;
AVCaptureStillImageOutput *imageOutput;
AVCaptureDevice *device;
AVCaptureDeviceInput* input;
int cameraIndex;
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
    self.submitButton.alpha = 0.0;
    self.redoButton.hidden = YES;
    
    session = [[AVCaptureSession alloc] init];
    //output = [[AVCaptureStillImageOutput alloc] init];
    //[session addOutput:output];
    self.imagePreview.hidden = YES;
    self.cameraButton.hidden = NO;
    questionTyped = NO;
    picCaptured = NO;
    cameraIndex = 0;
    [self cameraSetup:cameraIndex];
}

-(void)cameraSetup:(int)index {
    //Setup camera input
    NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //You could check for front or back camera here, but for simplicity just grab the first device
    device = [possibleDevices objectAtIndex:index];
    NSError *error = nil;
    // create an input and add it to the session
    [session removeInput:input];
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error]; //Handle errors
    //set the session preset
    session.sessionPreset = AVCaptureSessionPresetMedium; //Or other preset supported by the input device
    
    [session addInput:input];
    [session removeOutput:imageOutput];
    imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:imageOutput];
    
    videoConnection = nil;
    for (AVCaptureConnection *connection in imageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    //Set the preview layer frame
    previewLayer.frame = CGRectMake(0,0,self.previewView.frame.size.width,self.previewView.frame.size.width*4/3);
    //Now you can add this layer to a view of your view controller
    [self.previewView.layer addSublayer:previewLayer];
    [session startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.01];
    self.previewImage.frame = CGRectMake(40,115,240,240);
    [UIView commitAnimations];
    self.previewImage.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self performSegueWithIdentifier:@"backFromMakeQSegue" sender:self];
}

- (IBAction)onSubmit:(id)sender {
    NSMutableArray *friends = [friendsTable getCells];
    NSMutableArray *friendsList = [[NSMutableArray alloc]init];
    NSMutableArray *friendsNames = [[NSMutableArray alloc]init];
    for (FriendCell *cell in friends) {
        if (cell.sendToSwitch.on) {
            [friendsList addObject:cell.user];
            [friendsNames addObject:[cell.user objectForKey:@"UserName"]];
        }
    }
    if ([friendsList count]==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Uh-oh!"
                                                       message: @"You have to choose friends to send it to!"
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        return;
    }
    PFObject *qUpload = [PFObject objectWithClassName:@"Q"];
    [qUpload setObject:self.questionField.text forKey:@"Question"];
    PFRelation *senderRelation = [qUpload relationforKey:@"UserSender"];
    [senderRelation addObject:user];
    PFRelation *recipientsRelation = [qUpload relationforKey:@"UserRecipients"];
    for (PFUser *rec in friendsList) {
        [recipientsRelation addObject:rec];
    }
    [qUpload setObject:[user objectForKey:@"UserName"] forKey:@"SenderName"];
    NSData *imageData = UIImageJPEGRepresentation(self.previewImage.image, .8);
    PFFile *imageFile = [PFFile fileWithName:@"picture.jpg" data:imageData];
    [qUpload setObject:imageFile forKey:@"Picture"];
    
    UIImage *originalImage = self.previewImage.image;
    CGSize destinationSize = CGSizeMake(50.0,50.0);
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, .8);
    PFFile *thumbFile = [PFFile fileWithName:@"thumb.jpg" data:thumbData];
    [qUpload setObject:thumbFile forKey:@"Thumbnail"];
    [qUpload saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"UserName" containedIn:friendsNames];
        [PFPush sendPushMessageToQueryInBackground:pushQuery
                                       withMessage:[NSString stringWithFormat:@"You were popped a Q from %@",[user objectForKey:@"UserName"]]];
    }];
    [self performSegueWithIdentifier:@"backFromMakeQSegue" sender:self];
    

    
    

}

- (IBAction)onCamera:(id)sender {
    self.redoButton.hidden = NO;
    if ( videoConnection ) {
        [session startRunning];
        
        [imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer != NULL) {
                NSData *imageData = [AVCaptureStillImageOutput
                                     jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0,0,360,360));
                
                UIImage *squareImage = [UIImage imageWithCGImage:imageRef
                                          scale:image.scale
                                    orientation:image.imageOrientation];
                if (cameraIndex == 1) {
                    
                    UIImage* flippedImage = [UIImage imageWithCGImage:squareImage.CGImage
                                                                scale:1.0 orientation: UIImageOrientationLeftMirrored];
                    self.previewImage.image = flippedImage;
                } else {
                    self.previewImage.image = squareImage;
                }
                self.previewImage.hidden = NO;
                self.cameraButton.hidden = YES;
                self.flipButton.hidden = YES;
                picCaptured = YES;
                if ([self.questionField.text length] > 0) {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:.3];
                    self.submitButton.alpha = 1.0;
                    [UIView commitAnimations];
                    questionTyped = YES;
                }
                CFRelease(imageRef);
            }
            
        }];
    }
    if (questionTyped) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        self.submitButton.alpha = 1.0;
        [UIView commitAnimations];
    }
}

- (IBAction)onQuestionEdit:(id)sender {
    if (picCaptured) {
        if ([self.questionField.text length] > 0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.3];
            self.submitButton.alpha = 1.0;
            [UIView commitAnimations];
            questionTyped = YES;
        } else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.3];
            self.submitButton.alpha = 0.0;
            [UIView commitAnimations];
            questionTyped = NO;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.questionField.text length] >= 60) {
        self.questionField.text = [textField.text substringToIndex:60];
        return NO;
    }
    return YES;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"friendsEmbed"]) {
        friendsTable = (ChooseFriendsTableController *) [segue destinationViewController];
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
- (IBAction)onRedo:(id)sender {
    self.cameraButton.hidden = NO;
    picCaptured = NO;
    self.previewImage.hidden = YES;
    self.flipButton.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.submitButton.alpha = 0.0;
    [UIView commitAnimations];
    self.redoButton.hidden = YES;
}

- (IBAction)onFlip:(id)sender {
    if (cameraIndex) {
        cameraIndex = 0;
        [self cameraSetup:cameraIndex];
    } else {
        cameraIndex = 1;
        [self cameraSetup:cameraIndex];
    }
}
@end
