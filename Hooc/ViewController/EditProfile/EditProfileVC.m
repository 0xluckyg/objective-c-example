//
//  ViewController.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "EditProfileVC.h"
#import "InstructionsVC.h"

@interface EditProfileVC ()

@end

@implementation EditProfileVC
@synthesize dictData;
@synthesize cameFromSignUp;

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=FALSE;

    [self checkNotificationStatus];
    [self setInitialSettings];

}

//-----------------------------------------------------------------------

-(void) viewWillAppear:(BOOL)animated {
    
    if(![[AppDelegate sharedinstance] connected])
    {
        
        NSString *strGender=[[PFUser currentUser] objectForKey:kgender];
        NSString *strName=[[PFUser currentUser] objectForKey:kname];

        [lblGender setText:[strGender capitalizedString]];
        
        NSString *strCurrentlyHoocedWith =[[AppDelegate sharedinstance] nullcheck: [[PFUser currentUser] objectForKey:khoocedWith]];
        
        NSMutableArray *arrTemp1 = [[NSMutableArray alloc] init];
        
        if([strCurrentlyHoocedWith length]>0) {
            arrTemp1 = [[strCurrentlyHoocedWith componentsSeparatedByString:@","] mutableCopy];
        }
        
        NSString *strText=[NSString stringWithFormat:@"%lu Hoocs",(unsigned long)[arrTemp1 count]];
        [lblHooc setText:strText];
        
        [lblName setText:strName];
        
        imgviewProfilePic.image=[[AppDelegate sharedinstance] getImage:klocalPic];
        
        return;
        
    }
    
    if(!chosenImage) {
        [self bindData];
       // [self temp];
        
    }
    else {
        
        [[AppDelegate sharedinstance] showLoader];
        
        NSData *imageData = UIImageJPEGRepresentation(imgviewProfilePic.image,0.5f);
        
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
        
        [[AppDelegate sharedinstance] saveImage:imgviewProfilePic.image withName:klocalPic];
        
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                
                PFUser *user=[PFUser currentUser];
                
                user[@"ProfilePicture"] = imageFile;
                
                [user saveInBackground];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
                [[AppDelegate sharedinstance] hideLoader];

                [[AppDelegate sharedinstance] displayMessage:@"Updated profile picture"];
                
            }
        }];
        
    }
    
}

-(void) temp {
    
    // For more complex open graph stories, use `FBSDKShareAPI`
    // with `FBSDKShareOpenGraphContent`
    NSDictionary *params = @{
                                                    @"fields": @"context.fields(all_mutual_friends.fields(picture.width(200).height(200)).limit(8))",
                                                };
    /* make the API call */
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/1679866818924336"
                                  parameters:params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        NSDictionary *dictResult = (NSDictionary *)result;
        
        int count = [[[[[dictResult objectForKey:@"context"] objectForKey:@"all_mutual_friends"]objectForKey:@"summary"] objectForKey:@"total_count" ] intValue];
        NSLog(@"Mutual friends count : %d",count);

        NSArray *arr = [[[dictResult objectForKey:@"context"] objectForKey:@"all_mutual_friends"] objectForKey:@"data"];
        NSLog(@"Arr : %@",arr);
        
        NSString *strImageUrl  = [[[[arr objectAtIndex:0] objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        
        [imgviewProfilePic setImageWithURL:[NSURL URLWithString:strImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        // Handle the result
    }];
}
//
//    NSString *strRandomConnectedFBID=@"137423009948398";
//    
//    NSArray *arr = [NSArray arrayWithObjects:strRandomConnectedFBID,@"1679866818924336",nil];
//    
//    // Check this random id is present in connection table. If yes, then find some other random id, or else connect with him
//    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
//    [query whereKey:kuser2Id equalTo:strRandomConnectedFBID];
//    [query whereKey:kskippedBy notContainedIn:arr];
//    
//    PFQuery *query1 = [PFQuery queryWithClassName:@"Connection"];
//    [query1 whereKey:kuser1Id equalTo:strRandomConnectedFBID];
//    [query1 whereKey:kskippedBy notContainedIn:arr];
//    
//    PFQuery *query2 = [PFQuery queryWithClassName:@"Connection"];
//    [query2 whereKey:kuser1Id equalTo:[[PFUser currentUser] objectForKey:kfbId]];
//    [query2 whereKey:kskippedBy notContainedIn:arr];
//    
//    PFQuery *query3 = [PFQuery queryWithClassName:@"Connection"];
//    [query3 whereKey:kuser2Id equalTo:[[PFUser currentUser] objectForKey:kfbId]];
//    [query3 whereKey:kskippedBy notContainedIn:arr];
//    
//    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Connection"];
// //   [finalQuery whereKey:kskippedBy notContainedIn:arr];
//
//   finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query,query1,query2,query3,nil]];
//    
//    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
//        NSLog(@"results %@",results);
//        
//    }];
//}
//     
//-----------------------------------------------------------------------

- (BOOL)canOpenSettings
{
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    return canOpenSettings;
    
}

//-----------------------------------------------------------------------

-(void)checkNotificationStatus {
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

}
//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) setInitialSettings {
    
    BOOL userExists=[[NSUserDefaults standardUserDefaults] boolForKey:kuserExists];

    if(userExists) {
        [btnNext setHidden:YES];
    }
    else {
        [btnNext setHidden:NO];
    }
    
    
   
    self.navigationController.navigationBarHidden=YES;
    
    self.title=@"Edit your profile";
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
    [self setupMenuBarButtonItems];

    imgviewProfilePic.clipsToBounds=YES;
    imgviewProfilePic.layer.cornerRadius=imgviewProfilePic.frame.size.height/2;
    imgviewProfilePic.layer.borderWidth=0;
    imgviewProfilePic.layer.borderColor=[UIColor clearColor].CGColor;

    viewEdit.clipsToBounds=YES;
    viewEdit.layer.cornerRadius=viewEdit.frame.size.height/2;
    viewEdit.layer.borderWidth=0;
    viewEdit.layer.borderColor=[UIColor clearColor].CGColor;

    [self.view bringSubviewToFront:imgviewProfilePic];
    [self.view sendSubviewToBack:viewEdit];
    
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

-(void) bindData {
    
    [[AppDelegate sharedinstance] showLoader];
    
    PFQuery *query= [PFUser query];
    
    [AppDelegate sharedinstance].dictUserDetail=[[NSUserDefaults standardUserDefaults] objectForKey:kUserData];
    
    NSString *strEmail=[[AppDelegate sharedinstance].dictUserDetail objectForKey:@"email"] ;
    
    [query whereKey:@"email" equalTo:strEmail];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        [AppDelegate sharedinstance].objParseUser=object;
        
        NSString *strGender=[object objectForKey:kgender];
        NSString *strHooc=[object objectForKey:knoOfHoocs];
        NSString *strName=[object objectForKey:kname];

        strHooc=[NSString stringWithFormat:@"%@ Hoocs",strHooc];
        
        [lblGender setText:[strGender capitalizedString]];
        [lblHooc setText:strHooc];
        [lblName setText:strName];

        NSString *strCurrentlyHoocedWith =[[AppDelegate sharedinstance] nullcheck: [[PFUser currentUser] objectForKey:khoocedWith]];
        
        NSMutableArray *arrTemp1 = [[NSMutableArray alloc] init];
        
        if([strCurrentlyHoocedWith length]>0) {
            arrTemp1 = [[strCurrentlyHoocedWith componentsSeparatedByString:@","] mutableCopy];
        }
        
        NSString *strText=[NSString stringWithFormat:@"%lu Hoocs",(unsigned long)[arrTemp1 count]];
        [lblHooc setText:strText];
        imgviewProfilePic.image=[[AppDelegate sharedinstance] getImage:klocalPic];
        
        if(self.cameFromSignUp) {
            [self performSelector:@selector(hideLoaderCall) withObject:nil afterDelay:3.f];

        }
        else {
            [self performSelector:@selector(hideLoaderCall) withObject:nil afterDelay:.2f];

        }
        
    }];
    
}

//-----------------------------------------------------------------------

-(void) hideLoaderCall {
    [[AppDelegate sharedinstance] hideLoader];

}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

//-----------------------------------------------------------------------

-(IBAction)nextPressed:(id)sender {
    
    InstructionsVC *obj = [[InstructionsVC alloc] initWithNibName:@"InstructionsVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    
}

//-----------------------------------------------------------------------

-(IBAction)editProfile:(id)sender {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Select from Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

//-----------------------------------------------------------------------

#pragma mark UIAlertView delegate

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
}

//-----------------------------------------------------------------------

#pragma mark UIActionSheetDelegate

//-----------------------------------------------------------------------

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int i = buttonIndex;
    switch(i)
    {
        case 0:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                self.imagePickerController = picker;
                //                picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.allowsEditing = YES;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    self.popOver= [[UIPopoverController alloc] initWithContentViewController:picker];
                    [self.popOver presentPopoverFromRect:imgviewProfilePic.bounds inView:imgviewProfilePic permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
                }
                else {
                    [self presentViewController:self.imagePickerController animated:YES completion:nil];
                    
                }
            }
            else {
                [[[UIAlertView alloc] initWithTitle:kAppName message:@"Device does not supports camera" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                return;
            }
        }
            break;
        case 1:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePickerController = picker;
            picker.allowsEditing = YES;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                self.popOver= [[UIPopoverController alloc] initWithContentViewController:picker];
                [self.popOver presentPopoverFromRect:imgviewProfilePic.bounds inView:imgviewProfilePic permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            }
            else {
                [self presentViewController:self.imagePickerController animated:YES completion:nil];
                
            }
        }
        default:
            // Do Nothing.........
            break;
    }
}


//-----------------------------------------------------------------------

#pragma mark -
#pragma - mark Selecting Image from Camera and Library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    chosenImage=YES;
    
    // Picking Image from Camera/ Library
    
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (!image)
    {
        return;
    }
    
    // Adjusting Image Orientations
    
    imgviewProfilePic.image = image;
    
    if(IPAD) {
        [self.popOver dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:^{}];
    
   }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    chosenImage=NO;
    
    if(IPAD) {
        [self.popOver dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:^{}];
        
    }
}

@end
