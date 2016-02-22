//
//  AppDelegate.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginVC.h"
#import "kConstant.h"

@class LoginVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    LoginVC *obj_LoginVC;
    NSMutableDictionary *dictUserDetail;
    PFObject *objParseUser;
    FBSDKLoginManager *login;

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableDictionary *dictUserDetail;
@property (strong, nonatomic) NSDictionary *dictUserInfo;

@property (strong, nonatomic) PFObject *objParseUser;
@property (strong, nonatomic) FBSDKLoginManager *login;

@property (nonatomic,retain) LoginVC *obj_LoginVC;

+(AppDelegate*)sharedinstance;
-(void)displayMessage:(NSString *)str;
- (BOOL)connected;
-(NSString *) nullcheck:(NSString *) str;
-(void) applyCustomFontToView:(UIView *) view;
-(BOOL) validEmail:(NSString *)email;
-(void) showLoader;
-(void) hideLoader;
-(void)displayServerFailureMessage;
- (void)saveImage : (UIImage*)img withName : (NSString*)name;
- (UIImage*)getImage : (NSString*)name;
- (BOOL)notificationServicesEnabled;
-(void) registerForNotifications;
-(void) UnRegisterForNotifications;
-(BOOL) checkSubstring:(NSString *) substring containedIn:(NSString*) string;
-(void) sendPushTo:(NSString *)strId withMessage:(NSString*)strMessage withNotificationType:(NSString*) notificationType;

@end

