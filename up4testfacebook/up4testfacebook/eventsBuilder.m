//
//  eventsBuilder.m
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import "eventsBuilder.h"
#import "event.h"

@implementation eventsBuilder

+ (NSMutableDictionary *)eventsFromJSON:(id)objectNotation error:(NSError **)error
{
    
    NSError *localError = nil;
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableDictionary *events = [[NSMutableDictionary alloc] init];
    //NSMutableDictionary *eventsfriendscount = [[NSMutableDictionary alloc] init];
    
    NSArray *results = [objectNotation valueForKey:@"data"];
    NSArray *nameresults = [results valueForKey:@"name"];
    NSArray *resultsset = [results valueForKey:@"fql_result_set"];
    NSArray *eventsset = [resultsset objectAtIndex:[nameresults indexOfObject:@"events"]];
    //NSArray *friendsset = [resultsset objectAtIndex:[nameresults indexOfObject:@"friends"]];
    
    NSLog(@"Count %lu", (unsigned long)eventsset.count);
    
   /* for (NSDictionary *friendsDic in friendsset)
    {
        NSString *eid = [NSString stringWithFormat:@"%@", [friendsDic objectForKey:@"eid"]];
        int countfriends = 1;
        BOOL found = NO;
        
        for (NSString *str in [eventsfriendscount allKeys])
        {
            if ([str isEqualToString:eid])
            {
                if([[NSString stringWithFormat:@"%@", [friendsDic objectForKey:@"rsvp_status"]]isEqualToString:@"attending"]){
                    countfriends = [[eventsfriendscount objectForKey:eid] intValue];
                    countfriends++;
                    [eventsfriendscount setValue:[NSNumber numberWithInt:countfriends] forKey:eid];
                }
                found = YES;
            }
        }
        
        if (!found)
        {
            if([[NSString stringWithFormat:@"%@", [friendsDic objectForKey:@"rsvp_status"]]isEqualToString:@"attending"])
                [eventsfriendscount setValue:[NSNumber numberWithInt:countfriends] forKey:eid];
            
        }
    }*/
    
    for (NSDictionary *eventsDic in eventsset)
    {
        NSString *inputString = [eventsDic objectForKey:@"start_time"];
        NSString *dateString = [self dateFromJson:inputString format:@"yyyy-MM-dd"];
        
        BOOL found = NO;
        
        for (NSString *str in [events allKeys])
        {
            if ([str isEqualToString:dateString])
            {
                found = YES;
            }
        }
        
        if (!found)
        {
            [events setValue:[[NSMutableArray alloc] init] forKey:dateString];
        }
    }
    
    for (NSDictionary *eventsDic in eventsset)
    {
        NSString *inputString = [eventsDic objectForKey:@"start_time"];
        
        NSString *dateString = [self dateFromJson:inputString format:@"yyyy-MM-dd"];
        
        Event *event = [[Event alloc] init];
        [event setValue:[NSNumber numberWithInt:0] forKey:@"attending_friends"];
        for (NSString *key in eventsDic) {
            
            NSString *inputString = [eventsDic valueForKey:key];
            
            /*if([key isEqualToString:@"eid"]){
                
                for (NSString *str in [eventsfriendscount allKeys])
                {
                    if ([[NSString stringWithFormat:@"%@", inputString] isEqualToString:str])
                    {
                        [event setValue:[eventsfriendscount objectForKey:str] forKey:@"attending_friends"];
                        break;
                    }
                    else{
                        [event setValue:[NSNumber numberWithInt:0]forKey:@"attending_friends"];
                    }
                }
            }*/
            if([key isEqualToString:@"location"] )
            {
                if (!inputString || [inputString isKindOfClass:[NSNull class]])
                {
                [event setValue:@" " forKey:@"Location"];
                }else{
                [event setValue:inputString forKey:@"Location"];
                }
                
            }
            
            if ([event respondsToSelector:NSSelectorFromString(key)]) {
                
                if (!inputString || [inputString isKindOfClass:[NSNull class]])
                {
                    [event setValue:@" " forKey:key];
                }else{
                    
                    
                    if([key isEqualToString:@"start_time"]){
                        NSString *inputString = [eventsDic valueForKey:key];
                        NSString *timeString = [self dateFromJson:inputString format:@"HH'h'mm"];
                        [event setValue:timeString forKey:key];
                        
                    }else{
                        
                        [event setValue:inputString forKey:key];
                    }
                }
            }
        }
        
        [[events objectForKey:dateString] addObject:event];
    }
    
    for (NSString *key in [events allKeys])
    {
        [[events objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:YES]]];
    }
    
    return events;
}

+ (NSString *)dateFromJson:(NSString*)date format:(NSString*)format
{
   
    NSString *inputString = date;
    int length = [inputString length];

    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR_POSIX"]];
    if(length > 10){
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    NSDate *createdate = [dateFormatter dateFromString:inputString];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:createdate];
    
    return dateString;
}

@end