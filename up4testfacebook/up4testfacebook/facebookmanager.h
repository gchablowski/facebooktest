//
//  facebookmanager.h
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "facebookmanagerdelegate.h"
#import "facebookconnectordelegate.h"

@class facebookconnector;

@interface facebookmanager : NSObject<facebookconnectordelegate>

@property (strong, nonatomic) facebookconnector *communicator;
@property (weak, nonatomic) id<facebookmanagerdelegate> delegate;

- (void)fetchEvents:(int)begin to:(int)last;
@end