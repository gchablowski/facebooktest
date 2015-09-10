//
//  event.h
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *start_time;
@property (strong, nonatomic) NSNumber *all_members_count;
@property (strong, nonatomic) NSNumber *attending_count;
@property (strong, nonatomic) NSNumber *attending_friends;
@property (strong, nonatomic) NSString *pic_big;
@property (strong, nonatomic) NSString *Location;

@end
