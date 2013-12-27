//
//  Person.h
//  popQ
//
//  Created by Alex Koren on 9/28/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface Person : NSObject
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *phoneNumber;
@property BOOL isFriend;
@end
