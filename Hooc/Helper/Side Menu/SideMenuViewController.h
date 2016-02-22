//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

@interface SideMenuViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    IBOutlet UILabel *lblUserName;
    IBOutlet UIImageView *imgviewProfilePic;
}

@property (weak, nonatomic) IBOutlet UITableView *tbl_Menu;
@property(nonatomic,strong)NSMutableArray *muary_Menu;
@property(nonatomic,assign) BOOL shouldCallRefresh;

-(IBAction)logoutPressed:(id)sender;

@end