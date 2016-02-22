//
//  ViewController.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "LoginVC.h"
#import "EditProfileVC.h"

#define  kEmailCondition @"hooc"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBSDKLoginManager *login =[AppDelegate sharedinstance].login;
    
    if ( [FBSDKAccessToken currentAccessToken] ){
        [login logOut];
    }
    
    if(!login) {
        [AppDelegate sharedinstance].login = [[FBSDKLoginManager alloc] init];
    }
    
    [self setInitialSettings];
}

//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) setInitialSettings {

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    for(UIView *view in [scrollLogin subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
    NSMutableAttributedString *text =[[NSMutableAttributedString alloc]initWithAttributedString: lblLoginWithFB.attributedText];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:RGBCOLOR(44, 61, 84)
                 range:NSMakeRange(13, 8)];
    
    [lblLoginWithFB setAttributedText: text];
}

//-----------------------------------------------------------------------

-(BOOL) verifyEmail {

    if([[AppDelegate sharedinstance] validEmail:txtEmail.text]) {
        
        // if valid email, check kEmailCondition Found
        
        if (![txtEmail.text hasSuffix:@"@nyu.edu"]){
            [[AppDelegate sharedinstance] displayMessage:@"Email is not from a university we support"];
            
            return NO;
        }
        
        return YES;
        
//        if ([txtEmail.text rangeOfString:kEmailCondition].location == NSNotFound) {
//            NSLog(@"string does not contain ");
//            
//            return NO;
//            
//        } else {
//            NSLog(@"string contains !");
//            return YES;
//
//        }
    }
    
    return NO;
}

//-----------------------------------------------------------------------

-(IBAction)loginwithFB:(id)sender {

    if(![self verifyEmail])
        return;

    [[NSUserDefaults standardUserDefaults] setObject:txtEmail.text forKey:kUserLocalEmail];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[AppDelegate sharedinstance] showLoader];

    FBSDKLoginManager *login =[AppDelegate sharedinstance].login;

    if(!login) {
        [AppDelegate sharedinstance].login = [[FBSDKLoginManager alloc] init];
    }
    
    login.loginBehavior = FBSDKLoginBehaviorWeb;
    [login
     logInWithReadPermissions: @[@"public_profile",@"email",@"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         if (error) {
             [[AppDelegate sharedinstance] hideLoader];
             [[AppDelegate sharedinstance] displayMessage:[error localizedDescription]];
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             [[AppDelegate sharedinstance] hideLoader];
             
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                parameters:@{@"fields": @"gender,first_name, last_name, picture, email"}]
              startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                  if (!error) {
                      [AppDelegate sharedinstance].dictUserDetail=[result mutableCopy];
                      
                      [[NSUserDefaults standardUserDefaults ] setObject:[AppDelegate sharedinstance].dictUserDetail forKey:kUserData];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      
                     NSDictionary *dictUserDetail=result;
                      NSLog(@"Dict user detail %@",dictUserDetail);
                      [self saveDataInParse:dictUserDetail];
                      
                 }
                  else{
                      [[AppDelegate sharedinstance] displayMessage:[error localizedDescription]];

//                      NSLog(@"%@", [error localizedDescription]);
                  }
              }];
         }
     }];
    
}

//-----------------------------------------------------------------------

-(void) saveDataInParse:(NSDictionary *) dict {
    
   PFQuery *query = [PFUser query];
    
    NSString *strEmail;
    
    if(![dict objectForKey:@"email"]) {
        // We have not received email in response
    
        strEmail=[[NSUserDefaults standardUserDefaults] objectForKey:kUserLocalEmail];
    }
    else {
        strEmail=[dict objectForKey:@"email"];
    }
    
    [query whereKey:@"email" equalTo:strEmail];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object != nil) {
            [AppDelegate sharedinstance].objParseUser=object;

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kuserExists];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"User exist");
            PFFile *image = [object objectForKey:kprofilePicture];
            
            NSString *imageUrl = image.url;
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                /* Fetch the image from the server... */
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                UIImage *img = [[UIImage alloc] initWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* This is the main thread again, where we set the tableView's image to
                     be what we just fetched. */
                    
                    [PFUser logInWithUsernameInBackground:strEmail password:@"temp"
                                                    block:^(PFUser *user, NSError *error) {
                                                        if (user) {
                                                            // Do stuff after successful login.
                                                            [AppDelegate sharedinstance].objParseUser=user;

                                                            [[AppDelegate sharedinstance] saveImage:img withName:klocalPic];
                                                            isSignUp=YES;
                                                            isLogin=YES;
                                                            [self setController];
                                                        } else {
                                                            // The login failed. Check error to see why.
                                                        }
                                                    }];

                });
            });
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kisConnected];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kuserExists];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            PFUser *user = [PFUser user];
            user.username =strEmail;
            user.password = @"temp";
            [user setObject:strEmail forKey:kUserId];
            [user setObject:[dict objectForKey:@"gender"] forKey:kgender];
            [user setObject:strEmail forKey:kemail];
            [user setObject:@"1" forKey:kconnectionId];
            [user setObject:@"5" forKey:kratings];

            NSString *strUniversity=[self getUniversityIdForString:txtEmail.text];
             [user setObject:strUniversity forKey:kUniversityId];
            

            [[AppDelegate sharedinstance]showLoader];

           NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=1000&height=1000", [dict objectForKey:@"id"]];
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                /* Fetch the image from the server... */
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                UIImage *img = [[UIImage alloc] initWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* This is the main thread again, where we set the tableView's image to
                     be what we just fetched. */
                    
                    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
                    
                    [[AppDelegate sharedinstance] saveImage:img withName:klocalPic];
                    
                    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {

                            if (succeeded) {

                                user[@"ProfilePicture"] = imageFile;
                                
                                [user setObject:[dict objectForKey:@"id"] forKey:kfbId];
                                [user setObject:[NSNumber numberWithInt:0] forKey:knoOfHoocs];
                                
                                [user saveInBackground];
                                
                                NSString *strFname = [dict objectForKey:@"first_name"];
                               NSString *strLname = [dict objectForKey:@"last_name"];
                                
                                NSString *strName = [NSString stringWithFormat:@"%@ %@",strFname,strLname];
                                [user setObject:strName forKey:kname];
                                
                                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    
                                    if (!error) {
                                        [AppDelegate sharedinstance].objParseUser=user;
                                        isSignUp=YES;
                                        isLogin=NO;
                                        [self setController];
                                        
                                    } else {
                                        NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                                        [[AppDelegate sharedinstance] displayMessage:errorString];
                                    }
                                }];
                            }
                        } else {
                            [[AppDelegate sharedinstance] hideLoader];

                            // Handle error
                            NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                            [[AppDelegate sharedinstance] displayMessage:errorString];

                        }
                    }];
                     });
                });
              }
    }];
    
}

//-----------------------------------------------------------------------

-(NSString*) getUniversityIdForString:(NSString*) str {
    
    if ([txtEmail.text hasSuffix:@"@nyu.edu"]){
        
        return kNYU;
    }
    
    if ([txtEmail.text hasSuffix:@"@abc.xyz"]){
        
        return kABC;
    }
    
    return kNYU;
    
}

//-----------------------------------------------------------------------

-(void) setController
{
    [[AppDelegate sharedinstance] hideLoader];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[kfbId]=[[AppDelegate sharedinstance].objParseUser objectForKey:kfbId];
    [currentInstallation saveInBackground];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAlreadyLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    EditProfileVC *viewController=[[EditProfileVC alloc] initWithNibName:@"EditProfileVC" bundle:nil];
    viewController.cameFromSignUp=isSignUp;

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [nav.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName: [UIFont fontWithName:@"gillsans-light" size:25]}];
    
    SideMenuViewController *leftMenuViewController;
    leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    leftMenuViewController.shouldCallRefresh=NO;
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:nav
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    container.panMode=YES;
    
    
    [[AppDelegate sharedinstance].window setRootViewController:container];
}

//-----------------------------------------------------------------------

#pragma mark - UITextFieldDelegate Methods

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollLogin setContentOffset:CGPointMake(0, 100)animated:NO];
    [UIView commitAnimations];
    
    return YES;
}

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollLogin setContentOffset:CGPointMake(0, 0)animated:NO];
    [UIView commitAnimations];
    
    [textField resignFirstResponder];
    return YES;
}



@end
