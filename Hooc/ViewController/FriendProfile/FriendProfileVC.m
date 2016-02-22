//
//  ViewController.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "FriendProfileVC.h"
#import "EditProfileVC.h"
#import "ChatVC.h"

@interface FriendProfileVC ()

@end

@implementation FriendProfileVC
@synthesize strImageUrl;
@synthesize strGender;
@synthesize strMutualFriends;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setInitialSettings];
}

//-----------------------------------------------------------------------

-(void) viewWillAppear:(BOOL)animated {
    [lblGender setText:strGender];
    
    [imgviewProfilePic setImageWithURL:[NSURL URLWithString:strImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    lblHeader.text=[[NSUserDefaults standardUserDefaults] objectForKey:knameconnectedto];
}

//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) setInitialSettings {
    
    self.navigationController.navigationBarHidden=YES;
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
}


//-----------------------------------------------------------------------

- (void)setupMenuBarButtonItems {
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{

    ChatVC *obj = [[ChatVC alloc] initWithNibName:@"ChatVC" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:obj];
    
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
    

    
//    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
//        [self setupMenuBarButtonItems];
//    }];
}

@end
