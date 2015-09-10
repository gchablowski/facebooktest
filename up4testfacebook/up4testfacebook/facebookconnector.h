//
//  facebookconnector.h
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol facebookconnectordelegate;

@interface facebookconnector : NSObject

@property (weak, nonatomic) id<facebookconnectordelegate> delegate;

- (void)searchevents:(int)begin to:(int)last;

@end



