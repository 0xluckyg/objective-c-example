//
//  ViewController.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface EditProfileVC : UIViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    IBOutlet UIImageView *imgviewProfilePic;
    IBOutlet UIView *viewEdit;
    IBOutlet UILabel *lblGender;
    IBOutlet UILabel *lblHooc;
    IBOutlet UILabel *lblSkip;
    IBOutlet UILabel *lblName;
    IBOutlet UIButton *btnNext;
    
    NSDictionary *dictData;
    BOOL chosenImage;
}

@property(nonatomic,strong) NSDictionary *dictData;
@property (retain,nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, assign) BOOL cameFromSignUp;

-(IBAction)nextPressed:(id)sender;
-(IBAction)editProfile:(id)sender;

@end

