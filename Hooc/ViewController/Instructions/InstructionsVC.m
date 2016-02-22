//
//  ViewController.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "InstructionsVC.h"
#import "EditProfileVC.h"
#import "ChatVC.h"

@interface InstructionsVC ()

@end

@implementation InstructionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setInitialSettings];
}

//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) setInitialSettings {
  
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kuserExists];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    self.navigationController.navigationBar.topItem.backBarButtonItem = nil;
    self.navigationController.navigationBarHidden=YES;
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
        
    }
    
    for(UIView *view in [viewWhat subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
        
    }
    
    for(UIView *view in [viewGotIt subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
        
    }
    
    for(UIView *view in [viewOk subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
        
    }
    
    for(UIView *view in [viewGotIt subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
        
    }

    
    viewEdit.clipsToBounds=YES;
    viewEdit.layer.cornerRadius=viewEdit.frame.size.height/2;
    viewEdit.layer.borderWidth=0;
    viewEdit.layer.borderColor=[UIColor clearColor].CGColor;
}

//-----------------------------------------------------------------------

-(IBAction)nextPressed:(id)sender {
    [self.view addSubview:viewWhat];


}

//-----------------------------------------------------------------------

-(IBAction)whatPressed:(id)sender {
    [self.view addSubview:viewOk];

}

//-----------------------------------------------------------------------

-(IBAction)okPressed:(id)sender {
    [self.view addSubview:viewGotIt];
}

//-----------------------------------------------------------------------

-(IBAction)gotitPressed:(id)sender {
    ChatVC *obj=[[ChatVC alloc] initWithNibName:@"ChatVC" bundle:nil];
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
}

@end
