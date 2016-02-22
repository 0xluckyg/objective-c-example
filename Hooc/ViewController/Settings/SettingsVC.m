//
//  ViewController.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "SettingsVC.h"
#import "EditProfileVC.h"

@interface SettingsVC ()

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setInitialSettings];
    
    [self checkNotifiStatus];
}

//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) setInitialSettings {
    isOn=YES;
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
    viewEdit.clipsToBounds=YES;
    viewEdit.layer.cornerRadius=viewEdit.frame.size.height/2;
    viewEdit.layer.borderWidth=0;
    viewEdit.layer.borderColor=[UIColor clearColor].CGColor;
}

//-----------------------------------------------------------------------

- (BOOL)canOpenSettings
{
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    return canOpenSettings;
    
}

//-----------------------------------------------------------------------

-(void) checkNotifiStatus {
    
    if( [[[AppDelegate sharedinstance].objParseUser objectForKey:kisNotificationOn] isEqualToString:@"1"]) {
        isOn=YES;
        [btnOnOff  setTitle:@"ON" forState:UIControlStateNormal];
        
    }
    else {
        isOn=NO;
        [btnOnOff  setTitle:@"OFF" forState:UIControlStateNormal];
    }
    
}

//-----------------------------------------------------------------------

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"ico_menu"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(action_Menu:)];
}

//-----------------------------------------------------------------------

- (void)setupMenuBarButtonItems {
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

//-----------------------------------------------------------------------

-(IBAction)notificationPressed:(id)sender {

    if(isOn) {
        isOn=NO;
        
        [btnOnOff  setTitle:@"OFF" forState:UIControlStateNormal];
        
        [[AppDelegate sharedinstance] UnRegisterForNotifications];
        
        [[PFUser currentUser] setObject:@"0" forKey:kisNotificationOn];
        [[PFUser currentUser] saveInBackground];
        
    }
    else {
        isOn=YES;
        [btnOnOff  setTitle:@"ON" forState:UIControlStateNormal];
        [[AppDelegate sharedinstance] registerForNotifications];
        
        [[PFUser currentUser] setObject:@"1" forKey:kisNotificationOn];
        [[PFUser currentUser] saveInBackground];
        
        if(![[AppDelegate sharedinstance] notificationServicesEnabled]){
            
            if([self canOpenSettings]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"This app does not have access to notification service.\nYou can enable access in \nSettings->Hooc->Notifications.\nDo you want to be redirected to Settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag=121;
                [alert show];
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"This app does not have access to notification service.\nYou can enable access in \nSettings->Hooc->Notifications" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else {
            
        }

    }
}

//-----------------------------------------------------------------------

-(IBAction)deleteAccountPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Are you sure want to delete account?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag=122;
    [alert show];
 
}

//-----------------------------------------------------------------------

-(IBAction)websitePressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.google.com"]];

}

//-----------------------------------------------------------------------

-(IBAction)facebookPressed:(id)sender {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[@"<html><body><b>Hey, I am using a Hooc app.</b><br\\>Check out this amazing app : <a href='https://itunes.apple.com/ca/app/silverspaces/id1039593521?mt=8'> at app store</a></body></html>"] applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];

}

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 121)
    {
        if (buttonIndex == 0)
        {
        }
        else if (buttonIndex == 1)
        {
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    else if(alertView.tag==122){
        
      if (buttonIndex == 1)
        {
            [[PFUser currentUser] deleteInBackground];
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAlreadyLoggedIn];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            FBSDKLoginManager *login =[AppDelegate sharedinstance].login;

            if ( [FBSDKAccessToken currentAccessToken] ){
                [login logOut];
            }
            
            NSLog(@"Logged out of facebook");
            NSHTTPCookie *cookie;
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (cookie in [storage cookies])
            {
                NSString* domainName = [cookie domain];
                NSRange domainRange = [domainName rangeOfString:@"facebook"];
                if(domainRange.length > 0)
                {
                    [storage deleteCookie:cookie];
                }
            }
            
            LoginVC *loginView;
            
            loginView = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
            
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:loginView];
            navigationController.viewControllers = controllers;
            
            self.menuContainerViewController.panMode=NO;
            
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
        
    }
    
}

@end
