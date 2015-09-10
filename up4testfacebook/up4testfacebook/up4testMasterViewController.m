//
//  up4testMasterViewController.m
//  up4testfacebook
//
//  Created by gérald chablowski on 28/01/2014.
//  Copyright (c) 2014 up4test. All rights reserved.
//

#import "up4testMasterViewController.h"

#import "Event.h"
#import "facebookmanager.h"
#import "facebookconnector.h"


@interface up4testMasterViewController () <facebookmanagerdelegate> {
    NSMutableDictionary *_events;
    facebookmanager *_manager;
    NSMutableDictionary *Imagelist;
    UIView *LoginView;
}

- (IBAction)loginButton:(UIButton *)sender;
- (void)userLoggedIn;
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
@end

@implementation up4testMasterViewController

static int page = 0;
static BOOL connect = FALSE;

- (void)viewDidLoad
{
    [super viewDidLoad];
    Imagelist = [[NSMutableDictionary alloc] init];
    _manager = [[facebookmanager alloc] init];
    _manager.communicator = [[facebookconnector alloc] init];
    _manager.communicator.delegate = _manager;
    _manager.delegate = self;
    
    
    LoginView =[[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,self.view.frame.size.width,self.view.frame.size.height)];
    LoginView.tag = 1;
    LoginView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loginwall.png"]];
    [self.view addSubview:LoginView ];
    [self.view bringSubviewToFront:LoginView];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton addTarget:self
                    action:@selector(loginButton:)
          forControlEvents:UIControlEventTouchDown];
    loginButton.frame = CGRectMake(80.0, 210.0, 290.0, 45.0);
    
    
    UIImage *newButtonImage = [[UIImage imageNamed:@"buttonlogin.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
    [loginButton setBackgroundImage:newButtonImage forState:UIControlStateNormal];
    
    loginButton.backgroundColor = [UIColor clearColor];
    
    // Align the button in the center horizontally
    loginButton.frame = CGRectOffset(loginButton.frame,
                                     (self.view.center.x - (loginButton.frame.size.width / 2)),
                                     5);
    
    // Align the button in the center vertically
    loginButton.center = self.view.center;
    [LoginView addSubview:loginButton];
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email", @"user_events", @"friends_events"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                          
                                      }];
    }
    
    
}

- (IBAction)loginButton:(UIButton *)sender {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email", @"user_events", @"friends_events"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                          
                                      }];
    }
}

- (void)userLoggedIn {
    
    UIView *viewToRemove = [self.view viewWithTag:1];
    [viewToRemove removeFromSuperview];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
  /*  [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            
        } else {
            NSLog(@"user info: %@", error);
        }
    }];*/
    
    [_manager fetchEvents:page to:page+10];
    
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

#pragma mark - FacebooManagerDelegate

- (void)didReceiveEvents:(NSMutableDictionary *)events
{
    if(page > 0){
        for (NSMutableDictionary *key in events) {
            id myObj = [_events objectForKey:key];
            id obj = [events objectForKey:key];
            if (!myObj) {
                // The key was not already in self, so simply add it.
                [_events setObject:obj forKey:key];
            } else {
                for(Event *item in obj){
                    if([myObj containsObject:item]){
                    [[_events objectForKey:key] addObject:item];
                    }
                }
            }
        }
        for (NSString *key in [_events allKeys])
        {
            [[_events objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:YES]]];
        }

        
    }else{
        _events = events;
    }
    
    page++;
    connect = FALSE;
    
    [self.tableView reloadData];
}


- (void)fetchingEventsFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_events allKeys] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"SectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    headerView.layer.borderColor = [UIColor colorWithRed:(52/255.0) green:(62/255.0) blue:(67/255.0) alpha:1.0].CGColor;
    headerView.layer.borderWidth = 2.0f;
    
    NSString *date = [[[_events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CER"]];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"fr_FR_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *createdate = [dateFormatter dateFromString:date];
    
    NSString *sectionname = @"Aujourd'hui";
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:createdate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if(![today isEqualToDate:otherDate]) {
        NSUInteger unitFlags = NSDayCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date] toDate:createdate options:0];
        switch (ABS([components day])+1) {
            case 1:
                sectionname = @"Demain";
                break;
                
            default:
                sectionname = [NSString stringWithFormat:@"Dans %d jours",ABS([components day])+1];
                break;
        }
    }
    
    UILabel *titre = (UILabel *)[headerView viewWithTag:200];
    titre.font = [UIFont fontWithName:@"Calibri" size:18.0f];
    titre.text = sectionname;
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_events valueForKey:[[[_events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"eventCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell.layer.borderColor = [UIColor colorWithRed:(52/255.0) green:(62/255.0) blue:(67/255.0) alpha:1.0].CGColor;
    cell.layer.borderWidth = 2.0f;
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
    // Configuration de la cellule
    Event *cellValue = [[_events valueForKey:[[[_events allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    UILabel *NameLabel = (UILabel *)[cell viewWithTag:101];
    NameLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:14.0f];
    UILabel *DateLabel = (UILabel *)[cell viewWithTag:102];
    DateLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:18.0f];
    UILabel *LieuLabel = (UILabel *)[cell viewWithTag:103];
    LieuLabel.font = [UIFont fontWithName:@"Calibri" size:12.0f];
    UILabel *ParticipantLabel = (UILabel *)[cell viewWithTag:104];
    ParticipantLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:10.0f];
    UILabel *AmiLabel = (UILabel *)[cell viewWithTag:105];
    AmiLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:14.0f];
    UIImageView *Image = (UIImageView *)[cell viewWithTag:106];
    Image.layer.borderColor = [UIColor colorWithRed:(217/255.0) green:(217/255.0) blue:(217/255.0) alpha:1.0].CGColor;
    Image.layer.borderWidth = 3.0f;
    for (CALayer *layer in Image.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = Image.bounds;
    gradient.colors = @[(id)[[UIColor clearColor] CGColor],
                        (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor]];
    [Image.layer insertSublayer:gradient atIndex:0];
    
    
    NameLabel.text = cellValue.name;
    DateLabel.text = cellValue.start_time;
    LieuLabel.text = cellValue.Location;
    ParticipantLabel.text = [NSString stringWithFormat:@"%@/%@", cellValue.attending_count, cellValue.all_members_count];
    AmiLabel.text = [NSString stringWithFormat:@"%@ amis", cellValue.attending_friends];
    
   NSString *ImageURL = cellValue.pic_big;
    Image.image = [UIImage imageNamed:@"placeholder.png"];
    
    if ([Imagelist objectForKey:ImageURL]) {
        Image.image = [Imagelist objectForKey:ImageURL];
    } else {
        // set default user image while image is being downloaded
        Image.image = [UIImage imageNamed:@"placeholder.png"];
        
        // download the image asynchronously
        [self downloadImageWithURL:[NSURL URLWithString:ImageURL] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                 Image.image = image;
                
                // cache the image for use later (when scrolling up)
                [Imagelist setObject:image forKey:ImageURL];
            }
        }];
    }
    
    return cell;
}
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (([scrollView contentOffset].y + scrollView.frame.size.height) >= [scrollView contentSize].height && page > 0 &&connect==FALSE){
        [_manager fetchEvents:page*10+1 to:page*10+10];
        connect = TRUE;
    }
}

- (IBAction)logout:(UIButton *)sender {
    
  
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
        [self.view addSubview:LoginView ];
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email", @"user_events", @"friends_events"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                          
                                      }];
    }

}

- (IBAction)reloadButton:(UIButton *)sender {
    page = 1;
    connect = TRUE;
    [self.tableView setContentOffset:CGPointMake(0.0f, -self.tableView .contentInset.top) animated:YES];
    
    [_manager fetchEvents:page to:page+10];
}
@end
