//
//  eventsBuilder.h
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface eventsBuilder : NSObject

+ (NSMutableDictionary *)eventsFromJSON:(id)objectNotation error:(NSError **)error;
+ (NSString *)dateFromJson:(NSString*)date format:(NSString*)format;

@end

