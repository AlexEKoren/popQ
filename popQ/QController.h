//
//  QController.h
//  popQ
//
//  Created by Alex Koren on 9/24/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface QController : UIViewController
@property (strong,nonatomic) PFObject *q;
@property BOOL answered;

@end
