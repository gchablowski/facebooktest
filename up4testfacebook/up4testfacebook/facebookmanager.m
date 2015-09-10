//
//  facebookmanager.m
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//
#import "facebookmanager.h"
#import "eventsBuilder.h"
#import "facebookconnector.h"

@implementation facebookmanager

- (void)fetchEvents:(int)begin to:(int)last
{
    
    [self.communicator searchevents:begin to:last];
}

#pragma mark - facebookconnectordelegate
- (void)receivedeventsJSON:(id)objectNotation
{
    NSError *error = nil;
    NSMutableDictionary *events = [eventsBuilder eventsFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        [self.delegate fetchingEventsFailedWithError:error];
       
    } else {
        [self.delegate didReceiveEvents:events];
    }
}
- (void)fetchingGroupsFailedWithError:(NSError *)error
{
    [self.delegate fetchingEventsFailedWithError:error];
}

@end