//
//  ViewController.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FriendProfileVC : UIViewController
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UIImageView *imgviewProfilePic;
    IBOutlet UILabel *lblGender;
    IBOutlet UILabel *lblMutualFriends;
    IBOutlet UILabel *lblHeader;

}
@property (nonatomic,strong) NSString *strImageUrl;
@property (nonatomic,strong) NSString *strGender;

@property (nonatomic,strong) NSString *strMutualFriends;
@end

