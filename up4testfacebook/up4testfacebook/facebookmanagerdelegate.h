//
//  facebookmanagerdelegate.h
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

@protocol facebookmanagerdelegate

- (void)didReceiveEvents:(NSMutableDictionary *)events;
- (void)fetchingEventsFailedWithError:(NSError *)error;

@end
