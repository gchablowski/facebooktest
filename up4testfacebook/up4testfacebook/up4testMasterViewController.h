//
//  up4testMasterViewController.h
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface up4testMasterViewController : UITableViewController <FBLoginViewDelegate>

- (IBAction)logout:(UIButton *)sender;
- (IBAction)reloadButton:(UIButton *)sender;

@end

