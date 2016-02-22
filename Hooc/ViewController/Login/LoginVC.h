//
//  ViewController.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface LoginVC : UIViewController <UITextFieldDelegate,MFMailComposeViewControllerDelegate>
{
    IBOutlet UITextField *txtEmail;

    IBOutlet  UILabel *lblLoginWithFB;
    
    IBOutlet  UIScrollView *scrollLogin;
    
    BOOL isSignUp;
    BOOL isLogin;

}

-(IBAction)loginwithFB:(id)sender;

@end

