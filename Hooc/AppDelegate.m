//
//  AppDelegate.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "AppDelegate.h"
#import "kConstant.h"
#import "TopicsVC.h"
#import "ChatVC.h"
#import "EditProfileVC.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

static AppDelegate *delegate;

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize obj_LoginVC;
@synthesize dictUserDetail;
@synthesize objParseUser;
@synthesize dictUserInfo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   [UIApplication sharedApplication].networkActivityIndicatorVisible=FALSE;
    
    [Fabric with:@[[Crashlytics class]]];
    
    dictUserDetail=[[NSMutableDictionary alloc] init];
    
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"1jRx4gAZ0WBshhRPjWY01jbCll4EtfQEkyTcuUFZ"
                  clientKey:@"C4ivKrsgFAShbUp2hfwTQGtbsSi4ovq54pLmkeEu"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
   // Override point for customization after application launch.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if([self connected]) {
        
    }
    else {
        [self displayServerFailureMessage];
    }

    [self registerForNotifications];
    
    [self setRootViewController];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//-----------------------------------------------------------------------

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

//-----------------------------------------------------------------------

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//-----------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

//-----------------------------------------------------------------------
/*
 Printing description of userInfo:
 {
    aps =     {
            alert = G;
            badge = 1;
            sound = UILocalNotificationDefaultSoundName;
    };
    messageType = "Test Message";
 
    parsePushId = N77CPoiHSw;
 }
 */

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"userInfo %@",userInfo);
    
    //[PFPush handlePush:userInfo];
    
    NSString *aps = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    UIApplicationState state = [application applicationState];
    
    NSString *strNotificationType = [userInfo objectForKey:kNotificationType];
    
    self.dictUserInfo=userInfo;
    
    if([strNotificationType isEqualToString:kNotificationTypeConnection]) {
        // Received connection request
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connNotifiReceived" object:nil];

    }
    else  if([strNotificationType isEqualToString:kNotificationTypeMessage]) {
        // Received chat message
        
//        if (state == UIApplicationStateActive) {
//            NSString *str=aps;
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Received message" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alertView show];
//        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"chatMessageNotifiReceived" object:nil];

        
    }
    else  if([strNotificationType isEqualToString:kNotificationTypeSkipped]) {
        // Connected user skipped me
        [[NSNotificationCenter defaultCenter] postNotificationName:@"skipNotifiReceived" object:nil];

    }
    else {
                if (state == UIApplicationStateActive) {
                    NSString *str=aps;
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                }
    }
}

//-----------------------------------------------------------------------

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) setRootViewController {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    UINavigationController *navigationController;
    
    if([def boolForKey:kAlreadyLoggedIn]) {
        EditProfileVC *obj=[[EditProfileVC alloc]initWithNibName:@"EditProfileVC" bundle:nil];
        obj.cameFromSignUp=NO;
        navigationController=[[UINavigationController alloc] initWithRootViewController:[[EditProfileVC alloc] initWithNibName:@"EditProfileVC" bundle:nil]];
    }
    else {
        obj_LoginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
        navigationController=[[UINavigationController alloc] initWithRootViewController:obj_LoginVC];

    }
    
//    navigationController=[[UINavigationController alloc] initWithRootViewController:[[ChatVC alloc] initWithNibName:@"ChatVC" bundle:nil]];

    SideMenuViewController *leftMenuViewController;
    leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    
    [navigationController.navigationBar setTranslucent:NO];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:navigationController
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    
    if([def objectForKey:kAlreadyLoggedIn]) {
        container.panMode=YES;
    }
    else {
        container.panMode=NO;
    }
    
//    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor],}];
//    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    
    [self.window makeKeyAndVisible];
    self.window.rootViewController = container;
    
}

//-----------------------------------------------------------------------

-(void)displayServerFailureMessage {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Please check your network connection"delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

//-----------------------------------------------------------------------

-(void)displayMessage:(NSString *)str {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

//-----------------------------------------------------------------------

-(BOOL)connected {
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
        if(reachability != NULL) {
            //NetworkStatus retVal = NotReachable;
            SCNetworkReachabilityFlags flags;
            if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
                if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
                {
                    // if target host is not reachable
                    return NO;
                }
                
                if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
                {
                    // if target host is reachable and no connection is required
                    //  then we'll assume (for now) that your on Wi-Fi
                    return YES;
                }
                
                if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                     (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
                {
                    // ... and the connection is on-demand (or on-traffic) if the
                    //     calling application is using the CFSocketStream or higher APIs
                    
                    if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                    {
                        // ... and no [user] intervention is needed
                        return YES;
                    }
                }
                
                if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
                {
                    // ... but WWAN connections are OK if the calling application
                    //     is using the CFNetwork (CFSocketStream?) APIs.
                    return YES;
                }
            }
        }
        
        return NO;
}

//-----------------------------------------------------------------------

+(AppDelegate*)sharedinstance
{
    if (delegate==nil) {
        delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        return delegate;
    }
    return delegate;
}

//-----------------------------------------------------------------------

-(NSString *) nullcheck:(NSString *) str {
    if (str== nil || str == (id)[NSNull null]) {
        
        return @"";
    }
    return str;
    
}

//-----------------------------------------------------------------------

-(void) applyCustomFontToView:(UIView *) view {
    
    if([view isKindOfClass:[UILabel class]]) {
        UILabel *lbl = (UILabel *)view;
        CGFloat fontSize = lbl.font.pointSize;
        [lbl setFont: [UIFont fontWithName:@"gillsans-light" size:fontSize]];
    }
    else if([view isKindOfClass:[UITextField class]]) {
        UITextField *txtField = (UITextField *)view;
        CGFloat fontSize = txtField.font.pointSize;
        [txtField setFont: [UIFont fontWithName:@"gillsans-light" size:fontSize]];
    }
    else if([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        CGFloat fontSize = btn.titleLabel.font.pointSize;
        [btn.titleLabel setFont: [UIFont fontWithName:@"gillsans-light" size:fontSize]];
    }
    else if([view isKindOfClass:[UITextView class]]) {
        UITextView *txtView = (UITextView *)view;
        CGFloat fontSize = txtView.font.pointSize;
        [txtView setFont: [UIFont fontWithName:@"gillsans-light" size:fontSize]];
    }
}

//-----------------------------------------------------------------------

-(BOOL) validEmail:(NSString *)email {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [email stringByTrimmingCharactersInSet:whitespace];
    
    NSString *errorMessage;
    
    if([trimmed length]==0 ) {
        errorMessage = @"Please enter a valid email address";
        [[[UIAlertView alloc] initWithTitle:kAppName message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        return NO ;
    } else {
        
        NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        if (![emailPredicate evaluateWithObject:trimmed]){
            errorMessage = @"Please enter a valid email address";
            [[[UIAlertView alloc] initWithTitle:kAppName message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            return NO ;
        }
        else {
            return YES ;
        }
    }
}

//-----------------------------------------------------------------------

-(void) showLoader {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

}

//-----------------------------------------------------------------------

-(void) hideLoader {
    [SVProgressHUD  dismiss];

}

//-----------------------------------------------------------------------

- (UIImage*)getImage : (NSString*)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
}

//-----------------------------------------------------------------------

- (void)saveImage : (UIImage*)img withName : (NSString*)name {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:name]; //Add the file name
    NSData *pngData = UIImageJPEGRepresentation(img,0.5f);
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
}

//-----------------------------------------------------------------------

- (BOOL)notificationServicesEnabled {
    BOOL isEnabled = NO;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            isEnabled = NO;
        } else {
            isEnabled = YES;
        }
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types & UIRemoteNotificationTypeAlert) {
            isEnabled = YES;
        } else{
            isEnabled = NO;
        }
    }
    
    return isEnabled;
}

//-----------------------------------------------------------------------

-(void) registerForNotifications {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

//-----------------------------------------------------------------------

-(void) UnRegisterForNotifications {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

//-----------------------------------------------------------------------

-(BOOL) checkSubstring:(NSString *) substring containedIn:(NSString*) string {
    
    if ([string rangeOfString:substring].location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

//-----------------------------------------------------------------------

-(void) sendPushTo:(NSString *)strId withMessage:(NSString*)strMessage withNotificationType:(NSString*) notificationType{
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];

    [pushQuery whereKey:kfbId equalTo:strId];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          strMessage, @"alert",
                          notificationType, @"NotificationType",
                          @1,@"badge",
                          UILocalNotificationDefaultSoundName, @"sound",
                          nil];
    
    [push setData:data] ;

    if([notificationType isEqualToString:kNotificationTypeMessage]) {
        
    }
    else if([notificationType isEqualToString:kNotificationTypeConnection]) {
        // If you have a time sensitive notification that is not worth delivering late, you can set an expiration interval
        // We don't want to show user connection request to notify user by showing it.
        
//        NSTimeInterval interval = 5;
//        [push expireAfterTimeInterval:interval];

    }
    else if([notificationType isEqualToString:kNotificationTypeSkipped]) {
        
    }
    else if([notificationType isEqualToString:kNotificationTypeHooced]) {
           NSTimeInterval interval =15;
           [push expireAfterTimeInterval:interval];
    }

    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(!error){
            NSLog(@"Push sent");
        }else{
            NSLog(@"%@", error.userInfo);
        }
        
    }];
}

@end
