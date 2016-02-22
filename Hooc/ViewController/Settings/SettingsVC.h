//
//  ViewController.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsVC : UIViewController
{
    IBOutlet UIButton *btnOnOff;
    IBOutlet UIView *viewEdit;
    BOOL isOn;
}

-(IBAction)notificationPressed:(id)sender;
-(IBAction)deleteAccountPressed:(id)sender;
-(IBAction)websitePressed:(id)sender;
-(IBAction)facebookPressed:(id)sender;

@end

