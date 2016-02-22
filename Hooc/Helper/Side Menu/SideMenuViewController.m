//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "cell_Menu.h"
#import "NSString+FontAwesome.h"
#import "AppDelegate.h"
#import "kConstant.h"
#import "LoginVC.h"
#import "ChatVC.h"
#import "EditProfileVC.h"
#import "SettingsVC.h"

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent=NO;
    [self.navigationController setNavigationBarHidden:YES];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.muary_Menu=[[NSMutableArray alloc] initWithObjects:@"Random Chat",@"My Info",@"Settings",nil];
    
    self.tbl_Menu.tableFooterView = [UIView new];
    
    [self.tbl_Menu setBackgroundColor:[UIColor clearColor]];
    
    imgviewProfilePic.layer.cornerRadius = imgviewProfilePic.frame.size.width/2;
    [imgviewProfilePic.layer setMasksToBounds:YES];
    [imgviewProfilePic.layer setBorderColor:[UIColor clearColor].CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContent) name:@"refreshContent" object:nil];
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
    [self refreshContent];
    
    if(!self.shouldCallRefresh)
    {
        
    }
    else {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refreshContent {
    
    if(![[AppDelegate sharedinstance] connected]) {
        
        NSString *strName=[[PFUser currentUser] objectForKey:kname];
        
        [lblUserName setText:strName];
        
        imgviewProfilePic.image=[[AppDelegate sharedinstance] getImage:klocalPic];
        
        return;
        
    }
    
    imgviewProfilePic.image=[[AppDelegate sharedinstance] getImage:klocalPic];
    
    NSString *strFname =[[AppDelegate sharedinstance].dictUserDetail objectForKey:@"first_name"];
    NSString *strLname = [[AppDelegate sharedinstance].dictUserDetail objectForKey:@"last_name"];
    
    NSString *strName = [NSString stringWithFormat:@"%@ %@",strFname,strLname];
    [lblUserName setText:strName];
    
    //    [self.imgView_User setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    //
    //    NSString *first_name=   [[AppDelegate sharedinstance] nullcheck:[dicData objectForKey:@"first_name"]];
    //    [self.lbl_UserName setText:[NSString stringWithFormat:@"Hi %@!",first_name]];
}

//-----------------------------------------------------------------------

-(IBAction)logoutPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Are you sure want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag=121;
    [alert show];
}

//-----------------------------------------------------------------------

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//-----------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

//-----------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.muary_Menu count];
}

//-----------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_Menu *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_Menu"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_Menu" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    for(UIView *view in [cell.contentView subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
    self.tbl_Menu.separatorColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    self.tbl_Menu.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.lbl_Name.text =[self.muary_Menu objectAtIndex:indexPath.row];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    return cell;
    
}

//-----------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *viewController;
    
    if(indexPath.row==0) {
        viewController =[[ChatVC alloc] initWithNibName:@"ChatVC" bundle:nil];
        
    }
    else if (indexPath.row==1) {
        viewController =[[EditProfileVC alloc] initWithNibName:@"EditProfileVC" bundle:nil];
        
    }
    else if (indexPath.row==2) {
        viewController =[[SettingsVC alloc] initWithNibName:@"SettingsVC" bundle:nil];
        
    }
    
    UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
    [navigationController.navigationBar setTranslucent:NO];
    
    NSArray *controllers = [NSArray arrayWithObject:viewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

//-----------------------------------------------------------------------

#pragma mark - Alert Delegate

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 121)
    {
        if (buttonIndex == 0)
        {
        }
        else if (buttonIndex == 1)
        {
            [[AppDelegate sharedinstance] showLoader];
            
            [[AppDelegate sharedinstance] UnRegisterForNotifications];
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAlreadyLoggedIn];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            FBSDKLoginManager *login =[AppDelegate sharedinstance].login;

            if ( [FBSDKAccessToken currentAccessToken] ){
                [login logOut];
            }
            [FBSDKAccessToken setCurrentAccessToken:nil];
            [FBSDKProfile setCurrentProfile:nil];
            
            NSLog(@"Logged out of facebook");
            NSHTTPCookie *cookie;
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (cookie in [storage cookies])
            {
                NSString* domainName = [cookie domain];
                NSRange domainRange = [domainName rangeOfString:@"facebook"];
                if(domainRange.length > 0)
                {
                    [storage deleteCookie:cookie];
                }
            }
            
            NSString *strUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
            
            PFUser *user = [PFUser currentUser];
            [user setObject:@"0" forKey:kconnectionId];
            [user saveInBackground];
            
            [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
             
                [[AppDelegate sharedinstance] hideLoader];
                
                LoginVC *loginView;
                
                loginView = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
                
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:loginView];
                navigationController.viewControllers = controllers;
                
                self.menuContainerViewController.panMode=NO;
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }];
            
            
        }
    }
}



@end
