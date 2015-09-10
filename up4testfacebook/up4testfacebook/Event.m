//
//  event.m
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import "Event.h"

@implementation Event


- (BOOL)isEqual: (id)other
{
    return ([[other name] isEqual: _name] &&
            [[other start_time] isEqual: _start_time] &&
            [other all_members_count] == _all_members_count &&
            [other attending_count] == _attending_count &&
            [other attending_friends] == _attending_friends &&
            [[other pic_big] isEqual: _pic_big] &&
            [[other Location] isEqual: _Location]);
    
}

- (NSUInteger)hash
{
    return [_name hash] ^ [_start_time hash] ^ [_all_members_count hash] ^ [_attending_count hash] ^ [_attending_friends hash]^ [_pic_big hash]^ [_Location hash];
}
@end