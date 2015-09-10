//
//  facebookconnector.m
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import "facebookconnector.h"
#import "facebookconnectordelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation facebookconnector

- (void)searchevents:(int)begin to:(int)last
{
    NSLog(@"fisrt: %d , last : %d",begin, last);
   /* NSString *query =
    @"{"
    @"'events':'SELECT eid, name, venue, location, start_time, all_members_count, attending_count, timezone, pic_big,location FROM event WHERE eid IN"
    @"(SELECT eid FROM event_member WHERE (uid IN (SELECT uid2 FROM friend WHERE uid1 = me())  OR uid = me()))"
    @"AND start_time >= now() ORDER BY start_time asc LIMIT 3 ',"
    @"'friends':'SELECT uid, eid, rsvp_status FROM event_member WHERE eid IN (SELECT eid FROM #events)"
    @"AND uid IN (SELECT uid2 from friend where uid1 = me()) LIMIT 3',"
    @"}";*/
    
    NSString *query =[NSString stringWithFormat: @"{"
    @"'events':'SELECT eid, name, venue, location, start_time, all_members_count, attending_count, timezone, pic_big,location FROM event WHERE eid IN"
    @"(SELECT eid FROM event_member WHERE uid = me())"
    @"AND start_time >= now() ORDER BY start_time asc LIMIT %d, %d ',"
    @"}", begin, last];
    
    //NSLog(@"query : %@", query);
    
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  [self.delegate fetchingGroupsFailedWithError:error];
                              } else {
                                  //NSLog(@"user events: %@", result);
                                  [self.delegate receivedeventsJSON:result];
                              }
                          }];
        
}

@end