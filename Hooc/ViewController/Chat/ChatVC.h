//
//  ViewController.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "THChatInput.h"

@interface ChatVC : UIViewController <THChatInputDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    IBOutlet THChatInput *chatInput;
    IBOutlet UIScrollView *scrollMutualFriends;
    IBOutlet UIImageView *imgRatingStars;
    IBOutlet UIButton *btnOne,*btnTwo,*btnThree,*btnFour,*btnFive;
    IBOutlet UIView *viewRatings;
    IBOutlet UIView *viewHooc;
    IBOutlet UIView *viewSkip;
    IBOutlet UITableView *tblChat;
    IBOutlet UILabel *lblSaySomething;
    IBOutlet UILabel *lblConnecting;
    IBOutlet UILabel *lblHeader;

    NSMutableArray *arrChatObj;
    NSMutableArray *arrDateObj;

    CGRect tempFrame;
    
    int prevCount;
    NSString *strMessage;
    NSString *strConnectedFBID;
    NSString *strRandomConnectedFBID;
    NSString *strUserUniversity;
    int rateUser;
    NSString *strConnectedUserIds;
    NSString *strSavedConnId;
    NSString *strImgurl;
    NSTimer *timer;
    BOOL isAnyAvailable;
    
    NSString *strEmailConnectedTo;
    NSString *strNameConnectedTo;

    NSString *strHoocedBy;
    NSString *strSkippedBy;

    int tempCount;
    BOOL messageShown;
    
    NSMutableArray *arrSkippedUsers;
    BOOL newConnection;
    int countMutualFriends;
    NSString *strTimeChange;
    
    NSString *strObjId;
    NSString *strLastSavedChatObjId;
    NSString*strLastSendMessage;
    PFObject *objTemp;
    
    BOOL stopScrollToRow;
    float initialOffset;
    
    IBOutlet UIButton *btnTempHooc,*btnTempSkip;
}

@property (strong, nonatomic) IBOutlet THChatInput *chatInput;

-(IBAction)sendPressed:(id)sender;
-(IBAction)hoocPressed:(id)sender;
-(IBAction)skipPressed:(id)sender;
-(IBAction)submitPressed:(id)sender;
-(IBAction)ratingPressed:(id)sender;

@end

