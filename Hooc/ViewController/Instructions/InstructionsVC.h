//
//  ViewController.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface InstructionsVC : UIViewController
{
    
    IBOutlet UIView *viewEdit;
    IBOutlet UIView *viewWhat;
    IBOutlet UIView *viewOk;
    IBOutlet UIView *viewGotIt;
}

-(IBAction)nextPressed:(id)sender;
-(IBAction)whatPressed:(id)sender;
-(IBAction)okPressed:(id)sender;
-(IBAction)gotitPressed:(id)sender;

@end

