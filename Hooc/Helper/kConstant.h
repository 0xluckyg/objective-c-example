//
//  kConstant.h
//  DIBS
//
//  Created by Admin on 28/02/15.
//  Copyright (c) 2015 task. All rights reserved.
//

#ifndef DIBS_kConstant_h
#define DIBS_kConstant_h

#import "SideMenuViewController.h"

#import "MFSideMenuContainerViewController.h"
#import "MFSideMenu.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Parse/Parse.h>
#import <Crashlytics/Crashlytics.h>


#define kCOLORBLABK [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0]

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:r/225.0f green:g/225.0f blue:b/225.0f alpha:1]

#define kAppName @"Hooc"

#define kAlreadyLoggedIn @"AlreadyLoggedIn"

#define kDeviceToken @"MyDeviceToken"

#define kUserId @"UserId"

#define kUserData @"UserData"

#define kUserLocalEmail @"UserLocalEmai"

// Notification type

#define kSkippedMessage @"You are skipped by the connected person"
#define kHoocedMessage @"You are hooced by the connected person"

#define kNotificationTypeMessage @"1"
#define kNotificationTypeSkipped @"2"
#define kNotificationTypeConnection @"3"
#define kNotificationTypeHooced @"4"

#define kNotificationType @"NotificationType"

// Parse column name mapping

#define kobjectId @"objectId"

// university module
#define kuniversityName @"universityName"
#define kuniversityEmailEndWith @"universityEmailEndWith"
#define kUniversityId @"universityId"

#define kNYU @"NYU"
#define kABC @"ABC"

// user module
#define kfbId @"fbId"
#define kgender @"gender"
#define kisConnected @"isConnected"
#define kname @"name"
#define knoOfHoocs @"noOfHoocs"
#define kprofilePicture @"ProfilePicture"
#define kconnuserprofilePicture @"kconnuserprofilePicture"
#define kuserId @"userId"
#define kratings @"ratings"
#define kemail @"email"
#define kisNotificationOn @"isNotificationOn"
#define kisAvailable @"isAvailable"
#define khoocedWith @"hoocedWith"
#define kLocalhoocedWith @"LocalhoocedWith"

#define kuserExists @"userExists"


// chat module

#define kconnectionId @"connectionId"
#define kchatId @"chatId"
#define ktext @"text"
#define kconnectedUserIds @"connectedUserIds"
#define kRandomUserId @"RandomUserId"
#define kChatTime @"ChatTime"

#define kchatData @"chatData"

// connection module

#define kuser1Id @"user1Id"
#define kuser2Id @"user2Id"

#define khoocedBy @"hoocedBy"
#define kskippedBy @"skippedBy"
#define kConnStatus @"connStatus"

#define kConnStatusClosed @"0"
#define knameconnectedto @"nameconnectedto"
#define kgenderconnectedto @"nameconnectedto"
#define kmutualfriendsconnectedto @"nameconnectedto"

#define kCurrentUserHooced @"CurrentUserHooced"
#define kAreBothConnected @"AreBothConnected"

#define kUserHasSkipped @"UserHasSkipped"

// topics module

#define ktopicId @"topicId"
#define klikes @"likes"
#define klikedBy @"likedBy"

// Locally saved
#define klocalPic @"LocalPicture.png"


// Time change params
#define kChatTimeHeight @"strTimeChange"
#define kChatTimeRow @"strTimeChangerow"
//#define NSLog //
#endif
