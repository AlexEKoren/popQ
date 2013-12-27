//
//  RootController.h
//  popQ
//
//  Created by Alex Koren on 9/23/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeController.h"
@class HomeController;
@interface RootController : UIViewController <UIAlertViewDelegate>
-(void) setDelegate:(HomeController*)h;
@end
