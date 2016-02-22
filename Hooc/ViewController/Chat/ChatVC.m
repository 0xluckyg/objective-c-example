//
//  ViewController.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "ChatVC.h"
#import "TopicsVC.h"
#import "cell_Chat.h"
#import "FriendProfileVC.h"
#import "UIView+Toast.h"

#define kImageTag 1000
#define kMaxW 254
#define kMaxH 9999

#define kStatusAvailable 1
#define kStatusUnavailable 0

@interface ChatVC ()

@end

@implementation ChatVC
@synthesize chatInput;

//-----------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipNotifiReceived) name:@"skipNotifiReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connNotifiReceived) name:@"connNotifiReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageNotifiReceived) name:@"chatMessageNotifiReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hoocedNotifiReceived) name:@"hoocedNotifiReceived" object:nil];

    [self setInitialSettings];

    [tblChat setHidden:YES];
    [self addGestures];

}

//-----------------------------------------------------------------------

-(void) viewWillAppear:(BOOL)animated {
    
    [btnTempHooc setHidden:YES];
    [btnTempSkip setHidden:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kChatTimeRow];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL currentUserHasHooced = [[NSUserDefaults standardUserDefaults] boolForKey:kCurrentUserHooced];
    BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];

    if(currentUserHasHooced) {
        [viewHooc setUserInteractionEnabled:NO];
        [viewHooc setBackgroundColor:RGBCOLOR(255, 167, 167)];
    }
    else {
        if(bothHooced)
            [viewHooc setUserInteractionEnabled:NO];
        else
            [viewHooc setUserInteractionEnabled:YES];
        [viewHooc setBackgroundColor:RGBCOLOR(183, 72, 64)];
    }
    
    strImgurl=@"";
    rateUser=1;
    
    [PFNetworkActivityIndicatorManager sharedManager].enabled=NO;

    [tblChat setHidden:NO];
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    tempFrame=tblChat.frame;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.menuContainerViewController.panMode=YES;
    
    PFObject *object= [PFUser currentUser];
    strUserUniversity=[object objectForKey:kUniversityId];
    
    NSString *strConnectionId=[[PFUser currentUser] objectForKey:kconnectionId];

    if([strConnectionId isEqualToString:@"1"]) {
        PFUser *user = [PFUser currentUser];
        [user setObject:@"0" forKey:kconnectionId];
        [user saveInBackground];
    }
    
    strConnectionId=[[PFUser currentUser] objectForKey:kconnectionId];

  //  [self startTryingConnecting];

    if([strConnectionId isEqualToString:@"0"]) {
       [[AppDelegate sharedinstance] showLoader];
        newConnection=YES;

        [self startTryingConnecting];
        
    }
    else {
        NSString *strTopicText = [[NSUserDefaults standardUserDefaults] objectForKey:ktext];
        
        if([strTopicText length]>0) {
            chatInput.text=strTopicText;
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ktext];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.chatInput.textView becomeFirstResponder];
        }
        
        BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];
        if(bothHooced) {
            [viewHooc setUserInteractionEnabled:NO];
            [self changeLayoutAsBothConnected];
            
        }
        else {
            [viewHooc setUserInteractionEnabled:YES];
            [lblHeader setText:@"Mutual Friends : 0"];

        }
        [[AppDelegate sharedinstance] showLoader];
        
        for(int j=0;j<8;j++) {
            UIImageView *imgview = (UIImageView*)[scrollMutualFriends viewWithTag:kImageTag+j];
            [imgview setHidden:YES];
            
        }
        newConnection=NO;
        
        if(!bothHooced)
            [self startFetchingMutualFriends];
        
        [self refreshChatList];
        [self startTimer];
    }

    
}

//-----------------------------------------------------------------------

-(void) viewWillDisappear:(BOOL)animated {
    // Set user as unavailable
    
    [self stopTimer];
    
//    // If user is not connected, set it back to 1.
//    if([[[PFUser currentUser] objectForKey:kconnectionId] length]==1) {
//        
//        PFUser *user = [PFUser currentUser];
//        [user setObject:@"1" forKey:kconnectionId];
//        [user saveInBackground];
//        
//    }
}

//-----------------------------------------------------------------------

#pragma mark Connecting Method

//-----------------------------------------------------------------------

-(void) startTryingConnecting {
    
    BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];
    
    if(bothHooced) {
        [viewHooc setUserInteractionEnabled:NO];
        [self changeLayoutAsBothConnected];
        
    }
    else {
        [viewHooc setUserInteractionEnabled:YES];
        [lblHeader setText:@"Mutual Friends : 0"];
        [scrollMutualFriends setHidden:NO];
    }

    tempCount=0;
    [arrChatObj removeAllObjects];
    [tblChat reloadData];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserHasSkipped];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *strConnectionId=[[PFUser currentUser] objectForKey:kconnectionId];
    
   if([strConnectionId isEqualToString:@"0"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCurrentUserHooced];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAreBothConnected];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Not connected, so available
        // Look for a new connection
        
        // check if this user fb id is present in the connection table as User2Id (receiving side, if yes, then connect directly)
        
        PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
        [query setLimit: 1000];
        NSLog(@"Current fb id %@",[[PFUser currentUser] objectForKey:kfbId]);

        [query whereKey:kuser2Id equalTo:[[PFUser currentUser] objectForKey:kfbId]];//[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId]];
        [query whereKey:kskippedBy notContainedIn:[NSArray arrayWithObjects:[[PFUser currentUser] objectForKey:kfbId], nil]];

        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            
            if([results count]==0) {
                // No one send request, ready to be sender
                // Get all users who are of same university and connection id is 0(available)
                PFQuery *query=[PFUser query];
                [query setLimit: 1000];
                [query whereKey:kUniversityId equalTo:strUserUniversity];
                [query whereKey:kconnectionId equalTo:@"0"];
              //  [query whereKey:khoocedWith notContainedIn:[NSArray arrayWithObjects:[[PFUser currentUser] objectForKey:kfbId], nil]];
                [query whereKey:kfbId notEqualTo:[[PFUser currentUser] objectForKey:kfbId]];

//                NSMutableArray *array=[[NSUserDefaults standardUserDefaults] objectForKey:kLocalhoocedWith];
//                
//                if([array count]>0)
//                    [query whereKey:kfbId notContainedIn:[array copy]];

                // Exclude ourself
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    //    [[AppDelegate sharedinstance] hideLoader];
                    
                    if (!error) {
                        
                        if([objects count]==0) {
                            
                            if([[[PFUser currentUser] objectForKey:kconnectionId] length]<2) {
                                // No user available
                                [self  displayNoAvailability];
                                return ;
                            }
                            else {
                                [self messageAnimation];
                                    return ;
                            }
                   
                        }
                        
                        chatInput.userInteractionEnabled=YES;
                        [viewHooc setUserInteractionEnabled:YES];
                        [viewSkip setUserInteractionEnabled:YES];
                        
                        int randNum = arc4random() % (objects.count - 0) + 0;
                        
                        PFObject *object=[objects objectAtIndex:randNum];
                        strRandomConnectedFBID =[object objectForKey:kfbId];
                        
                      //   arrSkippedUsers
                        
//                        if([strRandomConnectedFBID isEqualToString:[[PFUser currentUser] objectForKey:kfbId]]) {
//                            [self  displayNoAvailability];
//                            
//                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:strRandomConnectedFBID forKey:kRandomUserId];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSLog(@"strRandomConnectedFBID %@",strRandomConnectedFBID);

                        strEmailConnectedTo=[object objectForKey:kemail];
                        strNameConnectedTo=[object objectForKey:kname];

                        [[NSUserDefaults standardUserDefaults] setObject:strNameConnectedTo forKey:knameconnectedto];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[object objectForKey:kgender] forKey:kgender];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSLog(@"\n strEmailConnectedTo %@",strEmailConnectedTo);

                        NSArray *arr = [NSArray arrayWithObjects:strRandomConnectedFBID,[[PFUser currentUser] objectForKey:kfbId],
                                            nil];
                        
                        // Check this random id is present in connection table. If yes, then find some other random id, or else connect with him
                        PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
                        [query whereKey:kuser2Id equalTo:strRandomConnectedFBID];
                        [query whereKey:kskippedBy notContainedIn:arr];
                        [query whereKey:khoocedBy notContainedIn:arr];

                        PFQuery *query1 = [PFQuery queryWithClassName:@"Connection"];
                        [query1 whereKey:kuser1Id equalTo:strRandomConnectedFBID];
                        [query1 whereKey:kskippedBy notContainedIn:arr];
                        [query1 whereKey:khoocedBy notContainedIn:arr];

                        PFQuery *query2 = [PFQuery queryWithClassName:@"Connection"];
                        [query2 whereKey:kuser1Id equalTo:[[PFUser currentUser] objectForKey:kfbId]];
                        [query2 whereKey:kskippedBy notContainedIn:arr];
                        [query2 whereKey:khoocedBy notContainedIn:arr];

                        PFQuery *query3 = [PFQuery queryWithClassName:@"Connection"];
                        [query3 whereKey:kuser2Id equalTo:[[PFUser currentUser] objectForKey:kfbId]];
                        [query3 whereKey:kskippedBy notContainedIn:arr];
                        [query3 whereKey:khoocedBy notContainedIn:arr];

                        PFQuery *finalQuery = [PFQuery queryWithClassName:@"Connection"];
                        
                        finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query,query1,query2,query3,nil]];
                        
                        [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                            
                            if([results count]==0) {
                          
                                NSString *strCurrentUserFBID=[[PFUser currentUser] objectForKey:kfbId];
                                
                                //NSArray *arr=[NSArray arrayWithObjects:strCurrentUserFBID,nil];
                                
                                PFObject *connectionObj = [PFObject objectWithClassName:@"Connection"];
                                
                                connectionObj[kuser1Id] =strCurrentUserFBID;
                                connectionObj[kuser2Id] =strRandomConnectedFBID;
                                
                                [connectionObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    
                                    if (succeeded) {
                                        
                                        strSavedConnId=connectionObj.objectId;
                                        
                                        // Check once again, if any present, delete our connection id and get that connection id
                                        
                                        [self manipulateDuplicateEntriesIfThereWithConnectionId:strSavedConnId WithUser1Id:strCurrentUserFBID withUser2Id:strRandomConnectedFBID withObj:connectionObj];
                                    }
                                }];
                            }
                            else {
                                // Not suitable, so trying to repeat the process
                                [self startTryingConnecting];
                            }
                        }];
                    }
                }];
            }
            else {
                
                PFObject *obj=(PFObject*)[results objectAtIndex:0];
                
                NSString *strReceiverConnectionId=[obj objectId];
                strRandomConnectedFBID=[obj objectForKey:kuser1Id];
                                        
                [[NSUserDefaults standardUserDefaults] setObject:strRandomConnectedFBID forKey:kRandomUserId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[PFUser currentUser] setObject:strReceiverConnectionId forKey:kconnectionId];
                
                [[PFUser currentUser] saveInBackground];

                [self messageAnimation];
                
                [self refreshChatList];
                [self startTimer];
            }
        }];
        
    }
}

//-----------------------------------------------------------------------

-(void) manipulateDuplicateEntriesIfThereWithConnectionId:(NSString *) strConnId WithUser1Id:(NSString*) strUser1Id withUser2Id:(NSString *) strUser2Id withObj:(PFObject*) connObj{
    
    NSString *strCurrentlyHoocedWith =[[AppDelegate sharedinstance] nullcheck: [[PFUser currentUser] objectForKey:khoocedWith]];
    
    NSArray *arr = [NSArray arrayWithObjects:strRandomConnectedFBID,[[PFUser currentUser] objectForKey:kfbId],
                    nil];
    
    // Check this random id is present in connection table. If yes, then find some other random id, or else connect with him
    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
    [query whereKey:kuser2Id equalTo:strRandomConnectedFBID];
    [query whereKey:kskippedBy notContainedIn:arr];
    [query whereKey:khoocedBy notContainedIn:arr];
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"Connection"];
    [query1 whereKey:kuser1Id equalTo:strRandomConnectedFBID];
    [query1 whereKey:kskippedBy notContainedIn:arr];
    [query1 whereKey:khoocedBy notContainedIn:arr];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Connection"];
    [query2 whereKey:kuser1Id equalTo:[[PFUser currentUser] objectForKey:kfbId]];
    [query2 whereKey:kskippedBy notContainedIn:arr];
    [query2 whereKey:khoocedBy notContainedIn:arr];
    
    PFQuery *query3 = [PFQuery queryWithClassName:@"Connection"];
    [query3 whereKey:kuser2Id equalTo:[[PFUser currentUser] objectForKey:kfbId]];
    [query3 whereKey:kskippedBy notContainedIn:arr];
    [query3 whereKey:khoocedBy notContainedIn:arr];
    
    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Connection"];
    
    finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query,query1,query2,query3,nil]];
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if([results count]==1) {
            
            if([strEmailConnectedTo isEqualToString:[[PFUser currentUser] objectForKey:kemail]]) {
                
                [self startTryingConnecting];
                
                return;
            }
            
            if([[AppDelegate sharedinstance] checkSubstring:strUser2Id containedIn:strCurrentlyHoocedWith] ) {
                
                if([[[PFUser currentUser] objectForKey:kconnectionId] length]<2) {
                    // No user available
                    [self  displayNoAvailability];
                    return ;
                }
                else {
                    [self messageAnimation];
                    return ;
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:strRandomConnectedFBID forKey:kRandomUserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Saving connection id for future purpose
            [[NSUserDefaults standardUserDefaults] setObject:strConnId forKey:kconnectionId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[PFUser currentUser] setObject:strConnId forKey:kconnectionId];
            
            [[PFUser currentUser] saveInBackground];
            
       //     [[AppDelegate sharedinstance] displayMessage:[NSString stringWithFormat:@"Connected with %@",strEmailConnectedTo]];

            [self messageAnimation];
        }
        else {
            [connObj deleteInBackground];
            
            [self startTryingConnecting];
        }
    }];
    
    
}

//-----------------------------------------------------------------------

#pragma mark - ConnectingAnimation

//-----------------------------------------------------------------------

-(void) startConnectingAnimation {
    
    [SVProgressHUD showWithStatus:@"Connecting to someone within your university" maskType:SVProgressHUDMaskTypeBlack];
}

//-----------------------------------------------------------------------

-(void) checkUserReadyToConnect {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
    [query setLimit: 1000];
    [query whereKey:kconnectionId equalTo:strSavedConnId];//[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        if([[[AppDelegate sharedinstance] nullcheck:object[kuser2Id]] length]>1) {
            // Receiver has set connection id into connection table.
            
            [[PFUser currentUser] setObject:strSavedConnId forKey:kconnectionId];
            
            [[PFUser currentUser] saveInBackground];
        }
    }];
}

//-----------------------------------------------------------------------

-(void) messageAnimation {
    [lblHeader setText:@"Mutual Friends : 0"];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected]) {
        lblSaySomething.text = @"Start chatting!";

        [self startTimer];
        
          [self startFetchingMutualFriends];
    }
    else {
        messageShown=NO;
        
        lblSaySomething.text = @"Start chatting!";
        [chatInput setUserInteractionEnabled:YES];

        [[AppDelegate sharedinstance]hideLoader];
        
        if(newConnection) {
            if([lblSaySomething isHidden]) {
                lblSaySomething.alpha = 0;
                [UIView animateWithDuration:1.0 animations:^{
                    lblSaySomething.hidden = NO;
                    
                    lblSaySomething.alpha = 1;
                    
                }];
            }
       
            
        }
    }
}

//-----------------------------------------------------------------------

-(void) startFetchingMutualFriends {
    // For more complex open graph stories, use `FBSDKShareAPI`
    // with `FBSDKShareOpenGraphContent`
    NSDictionary *params = @{
                             @"fields": @"context.fields(mutual_friends.fields(picture.width(200).height(200)).limit(10))",
                             };
    
    NSString *strConnId = [NSString stringWithFormat:@"/%@",[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId]];
    
    /* make the API call */
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:strConnId
                                  parameters:params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        NSDictionary *dictResult = (NSDictionary *)result;
        
        countMutualFriends= [[[[[dictResult objectForKey:@"context"] objectForKey:@"mutual_friends"]objectForKey:@"summary"] objectForKey:@"total_count" ] intValue];
        NSLog(@"Mutual friends count : %d",countMutualFriends);
        
        NSString *strCountMutualFriends = [NSString stringWithFormat:@"Mutual Friends : %d",countMutualFriends];
        [lblHeader setText:strCountMutualFriends];
        [scrollMutualFriends setHidden:YES];

//        NSMutableArray *arr = [[[[dictResult objectForKey:@"context"] objectForKey:@"mutual_friends"] objectForKey:@"data"] mutableCopy];
//
////        [arr addObjectsFromArray:arr];
////        [arr addObjectsFromArray:arr];
//        
//        NSLog(@"Arr : %@",arr);
//        [scrollMutualFriends setHidden:YES];
//        
//        if([arr count]==0) {
//            [scrollMutualFriends setHidden:YES];
//            tempFrame.origin.y=65;
//            tempFrame.size.height=427;
//            [tblChat setFrame:tempFrame];
//            
//        }
//        else {
//            
//            BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];
//
//            if(!bothHooced) {
//                [scrollMutualFriends setHidden:NO];
//
//            }
//            
//            tempFrame.origin.y=125;
//            tempFrame.size.height=367;
//            [tblChat setFrame:tempFrame];
//        }
//        
//        for(int j=0;j<10;j++) {
//            UIImageView *imgview = (UIImageView*)[scrollMutualFriends viewWithTag:kImageTag+j];
//            [imgview setHidden:YES];
//            
//        }
//        
//        for(int i=0;i<[arr count];i++) {
//            NSString *strImageUrl  = [[[[arr objectAtIndex:i] objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
//            
//           UIImageView *imgview = (UIImageView*)[scrollMutualFriends viewWithTag:kImageTag+i];
//            [imgview setHidden:NO];
//       
//            [imgview setImageWithURL:[NSURL URLWithString:strImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
//            
//            
//            if(i==4) {
//                NSLog(@"Frame of 5 %f", imgview.frame.origin.x);
//            }
//        }
//        
//        if([arr count]<6) {
//            [scrollMutualFriends setUserInteractionEnabled:NO];
//        }
//        else {
//            [scrollMutualFriends setUserInteractionEnabled:YES];
//        }
        
        messageShown=NO;
        
        lblSaySomething.text = @"Start chatting!";
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserHasSkipped];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[AppDelegate sharedinstance]hideLoader];
        [chatInput setUserInteractionEnabled:YES];

        if(newConnection) {
            if([lblSaySomething isHidden]) {
                lblSaySomething.alpha = 0;
                [UIView animateWithDuration:1.0 animations:^{
                    lblSaySomething.hidden = NO;
                    
                    lblSaySomething.alpha = 1;
                    
                }];
            }
           

        }
    }];

}

//-----------------------------------------------------------------------

-(void) noAvailabilityMessage {
    [lblHeader setText:@"Mutual Friends : 0"];
    [scrollMutualFriends setHidden:NO];
    
    isAnyAvailable=NO;
    chatInput.userInteractionEnabled=NO;

    [[AppDelegate sharedinstance]hideLoader];
    
    
    lblSaySomething.text = @"Hooc will notify you as soon as some one connects you";
    
    [self startTryingConnecting];
    [viewHooc setUserInteractionEnabled:NO];
    [viewSkip setUserInteractionEnabled:NO];
    [scrollMutualFriends setHidden:YES];

    if(!messageShown) {
        lblSaySomething.alpha = 0;
        
        [UIView animateWithDuration:1.0 animations:^{
            lblSaySomething.hidden = NO;

            lblSaySomething.alpha = 1;
            messageShown=YES;
            [chatInput setUserInteractionEnabled:YES];
            
        }];
    }
    
        //        [UIView animateWithDuration:2.0 animations:^{
        //            lblSaySomething.alpha = 0;
        //
        //        } completion: ^(BOOL finished) {//creates a variable (BOOL) called "finished" that is set to *YES* when animation IS completed.
        //            lblSaySomething.hidden = finished;//if animation is finished ("finished" == *YES*), then hidden = "finished" ... (aka hidden = *YES*)
        //            //            [chatInput.textView becomeFirstResponder];
        //            
        //        }];
   
}

//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) displayNoAvailability {
    [[AppDelegate sharedinstance] hideLoader];

    if([[[PFUser currentUser] objectForKey:kconnectionId] length]<2) {
        [self noAvailabilityMessage];

    }
    else {
        [self messageAnimation];
    }
    
    return;
}

//-----------------------------------------------------------------------

-(void) skipNotifiReceived {
    // When other user skipped, I get notification, and need to show rating view
    
    [self.view bringSubviewToFront:viewRatings];
    [viewRatings setHidden:NO];
}

//-----------------------------------------------------------------------

-(void) chatMessageNotifiReceived {
    [self refreshChatList];
}

//-----------------------------------------------------------------------

-(void) hoocedNotifiReceived {
    
}

//-----------------------------------------------------------------------

-(void) connNotifiReceived {
    
    // When other user tries to connect, get conn id and store it in user obj
    
    NSString *strConnId = [[[AppDelegate sharedinstance].dictUserInfo  objectForKey:@"aps"] objectForKey:@"alert"];

    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
    [query setLimit: 1000];
    [query whereKey:kconnectionId equalTo:strConnId];//[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        object[kuser2Id]=[[PFUser currentUser] objectForKey:kfbId];
        
        [object saveInBackground];

        [self performSelector:@selector(checkConnectionCount) withObject:nil afterDelay:3.f];
        
    }];

}

 //-----------------------------------------------------------------------

-(void) checkConnectionCount
{
    NSString *strConnId = [[[AppDelegate sharedinstance].dictUserInfo  objectForKey:@"aps"] objectForKey:@"alert"];

    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
    [query setLimit: 1000];
    [query whereKey:kconnectionId equalTo:strConnId];//[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if([results count]==1) {
            // User 1 is connected, so now set connection id to User 2 i.e Myself and show message animation
            
            [[PFUser currentUser] setObject:strConnId forKey:kconnectionId];
            
            [self messageAnimation];
            
            [self refreshChatList];
        }
    
    }];
    
}

//-----------------------------------------------------------------------

-(void) setInitialSettings {
    
    arrChatObj=[[NSMutableArray alloc] init];

    arrSkippedUsers=[[NSMutableArray alloc] init];
    
    [lblSaySomething setHidden:YES];
    
    [viewRatings setHidden:YES];
    
    self.title=@"Mutual Friends:";

    self.navigationController.navigationBarHidden=YES;
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
    int i=0;
    
    for(UIImageView *imgView in [scrollMutualFriends subviews]) {
        
        [imgView setTag:kImageTag+i];
        i++;
        
         NSLog(@"Frame of 5 %f", imgView.frame.origin.x);
        imgView.contentMode=UIViewContentModeScaleToFill;

        CGRect frame = imgView.frame;
//        int x = frame.origin.x ;
//        frame.origin.x=x;
        frame.size.width=50;
        frame.size.height=50;

        imgView.frame=frame;
        
        [imgView setImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        imgView.clipsToBounds=YES;
        imgView.layer.cornerRadius=imgView.frame.size.height/2;
        imgView.layer.borderWidth=0;
        imgView.layer.borderColor=[UIColor clearColor].CGColor;
        
        imgView.hidden=YES;
    }
    
    [scrollMutualFriends setContentSize:CGSizeMake(640, scrollMutualFriends.frame.size.height )];
}

//-----------------------------------------------------------------------

-(void) addGestures {
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    recognizer.numberOfTouchesRequired = 1;
   recognizer.delegate = self;
    [tblChat addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [tapRec setNumberOfTapsRequired:1];
    [tapRec setCancelsTouchesInView:NO];
    [tblChat addGestureRecognizer:tapRec];

}

//-----------------------------------------------------------------------

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    [chatInput setText:@""];
    [chatInput resignFirstResponder];
}

//-----------------------------------------------------------------------

-(void)swipeHandler:(UISwipeGestureRecognizer *)sender {
      [self pushTopicsVC];
    
}

//-----------------------------------------------------------------------

-(void) pushTopicsVC {
    TopicsVC *obj=[[TopicsVC alloc] initWithNibName:@"TopicsVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}

//-----------------------------------------------------------------------

-(void)sendMessage
{
    stopScrollToRow=NO;

    [lblSaySomething setHidden:YES];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"hh:mm a"];
    NSString *string = [formatter stringFromDate:[NSDate date]];
    
     NSDate *date1 = [formatter dateFromString:string];

    PFObject *chatObj = [PFObject objectWithClassName:@"Chat"];
   
    strTimeChange=[[NSUserDefaults standardUserDefaults] objectForKey:kChatTimeRow];
    NSDate *date2 = [formatter dateFromString:strTimeChange];

    NSLog(@"//----------------------------------------------------------------------");
    NSLog(@"Str current time %@,   stored time %@",string,strTimeChange);
    NSLog(@"Date 1 %@,   Date 2  %@",date1,date2);

    NSLog(@"//----------------------------------------------------------------------");
    
     if(([strTimeChange length]==0) ||  ([date1 compare:date2] == NSOrderedDescending))
         //         if(([strTimeChange length]==0) || (![strTimeChange isEqualToString:string] ) ||  ([date1 compare:date2] == NSOrderedDescending))
    {
        NSString *strCurrentUserFBID=[[PFUser currentUser] objectForKey:kfbId];
        chatObj[kuserId]=strCurrentUserFBID;
        chatObj[kconnectionId]=[[PFUser currentUser] objectForKey:kconnectionId]; //[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId];
        chatObj[ktext]=chatInput.text;
        
        [chatObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            //    objTemp=chatObj;
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                //            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                
                NSDate *date=chatObj.createdAt;
                [formatter setDateFormat:@"hh:mm a"];
                
                strTimeChange = [formatter stringFromDate:date];
                
                [[NSUserDefaults standardUserDefaults] setObject:strTimeChange forKey:kChatTimeRow];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                strLastSavedChatObjId=chatObj.objectId;
                strLastSendMessage=chatObj[ktext];
                strConnectedFBID=[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId];
                
                [self performSelector:@selector(sendPushInBg) withObject:nil afterDelay:2.f];
                
                // [[AppDelegate sharedinstance] sendPushTo:@"142814439411421" withMessage:chatInput.text withNotificationType:kNotificationTypeMessage];
                
                [self refreshChatList];
                [self startTimer];
                
                [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:1.f];
             
            } else {
                
                // There was a problem, check error.description
            }
        }];
    }
    else {
        
        chatObj= [PFObject objectWithoutDataWithClassName:@"Chat" objectId:objTemp.objectId];
        
        strLastSendMessage=[objTemp objectForKey:ktext];
        
        strLastSendMessage=[NSString stringWithFormat:@"%@\n%@",strLastSendMessage,chatInput.text];
        
        objTemp[ktext]=strLastSendMessage;
        
        [objTemp saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self refreshChatList];
                [self startTimer];
                [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:1.f];
            }
        }];
    }
   
}

-(void) scrollToBottom {
    if(arrChatObj.count>0) {
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:arrChatObj.count-1 inSection:0];
        
        [tblChat scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
  
}

 //-----------------------------------------------------------------------

-(void) sendPushInBg{
    
    PFObject *objConn = [PFObject objectWithoutDataWithClassName:@"Connection" objectId:[[PFUser currentUser] objectForKey:kconnectionId]] ;
    
    [objConn fetchIfNeededInBackgroundWithBlock:^(PFObject *objConn, NSError *error) {
        strHoocedBy=[objConn objectForKey:khoocedBy];
        strSkippedBy=[objConn objectForKey:kskippedBy];
        
//        NSLog(@"strHoocedBy %@",strHoocedBy);
//        NSLog(@"strSkippedBy %@",strSkippedBy);
        
        if([strSkippedBy length]>0) {
            //  Connected user skipped me
            
            [[PFUser currentUser] setObject:@"0" forKey:kconnectionId];
            [[PFUser currentUser] saveInBackground];
            
            [self.view bringSubviewToFront:viewRatings];
            [viewRatings setHidden:NO];
        }
        else {
            [[AppDelegate sharedinstance] sendPushTo:strConnectedFBID withMessage:strMessage withNotificationType:kNotificationTypeMessage];
        }
    }];
}

//-----------------------------------------------------------------------

-(void) checkConnectionStatus
{
    [[PFUser currentUser] fetchIfNeededInBackground];
    
    PFQuery *objConn = [PFQuery queryWithClassName:@"Connection"];
    [objConn whereKey:kobjectId equalTo:[[PFUser currentUser] objectForKey:kconnectionId]];
    
    [objConn findObjectsInBackgroundWithBlock:^(NSArray *objConn, NSError *error) {
    
        strHoocedBy=[[objConn objectAtIndex:0] objectForKey:khoocedBy];
        strSkippedBy=[[objConn objectAtIndex:0] objectForKey:kskippedBy];
        
        strHoocedBy =[[AppDelegate sharedinstance] nullcheck: strHoocedBy];
        strSkippedBy =[[AppDelegate sharedinstance] nullcheck: strSkippedBy];

//        NSLog(@"strHoocedBy %@",strHoocedBy);
//        NSLog(@"strSkippedBy %@",strSkippedBy);
        
        BOOL userHasSkipped=[[NSUserDefaults standardUserDefaults] boolForKey:kUserHasSkipped];
      
        if(!userHasSkipped) {
            
            if([strSkippedBy length]>0) {
                //  Connected user skipped me
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserHasSkipped];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self stopTimer];
         
                [PFObject deleteAllInBackground:objConn];
                
//                [[PFUser currentUser] setObject:@"0" forKey:kconnectionId];
//
//                [[PFUser currentUser] saveInBackground];
                
                [self.view bringSubviewToFront:viewRatings];
                [viewRatings setHidden:NO];
            }
        }
        
        BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];
       
       if(!bothHooced)
        {
            NSMutableArray *arr=[[strHoocedBy componentsSeparatedByString:@","] mutableCopy];
            
            if([arr count]>=2) {
            ///    [self stopTimer];

                [arr removeObject:[[PFUser currentUser]  objectForKey:kfbId]];
                
                NSString *strCurrentlyHoocedWith =[[AppDelegate sharedinstance] nullcheck: [[PFUser currentUser] objectForKey:khoocedWith]];
                NSMutableArray *arrTemp1 = [[NSMutableArray alloc] init];
                
                if([strCurrentlyHoocedWith length]>0)
                    arrTemp1 = [[strCurrentlyHoocedWith componentsSeparatedByString:@","] mutableCopy];
                
           //     NSLog(@"random connected id %@",[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId]);
                
                [arrTemp1 addObject:[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId]];
                
                [viewHooc setUserInteractionEnabled:NO];
                
            NSMutableArray *array= [[NSMutableArray alloc] init];
            //    [array addObject:[[NSUserDefaults standardUserDefaults] objectForKey:kLocalhoocedWith]];
                
             //   NSString *str=[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId];
                
              // [array addObject:str];
                
//                [[NSUserDefaults standardUserDefaults] setObject:array forKey:kLocalhoocedWith];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self changeLayoutAsBothConnected];
                
                arrTemp1 = [arrTemp1 valueForKeyPath:@"@distinctUnionOfObjects.self"];

//                [arrTemp1 removeObject:[[PFUser currentUser] objectForKey:kfbId]];
                
                NSString *strFinalIds =[[arrTemp1 valueForKey:@"description"] componentsJoinedByString:@","];
                
                [[PFUser currentUser] setObject: strFinalIds forKey:khoocedWith];
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        // The object has been saved.
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAreBothConnected];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                    } else {
                        // There was a problem, check error.description
                    }
                }];
                
            //    [self startTimer];

            }
        }
        
    }];
    
}

//-----------------------------------------------------------------------

-(void) changeLayoutAsBothConnected {
    
    [lblHeader setText:[[NSUserDefaults standardUserDefaults] objectForKey:knameconnectedto]];
    
    [viewHooc setBackgroundColor:RGBCOLOR(183, 72, 64)];
    [viewSkip setBackgroundColor:RGBCOLOR(44, 61, 84)];
    
    [scrollMutualFriends setHidden:YES];

//    tempFrame.origin.y=62;
//    tempFrame.size.height=432;
//
//    [tblChat setFrame:tempFrame];
    tempFrame=tblChat.frame;
    
    [tblChat reloadData];
}

//-----------------------------------------------------------------------

-(void) startTimer {
    if(timer) {
        [timer invalidate];
        timer=nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3.f
                                             target: self
                                           selector: @selector(refreshChatList)
                                           userInfo: nil
                                            repeats: YES];
    
}

//-----------------------------------------------------------------------

-(void) stopTimer {
    
    [timer invalidate];
    timer=nil;
}

//-----------------------------------------------------------------------

-(void) refreshChatList {

    ++tempCount;

    if(tempCount%3==0) {
        [self performSelector:@selector(checkConnectionStatus) withObject:nil afterDelay:2.0];
    }
    
    if([strImgurl length]==0) {
        PFQuery *userQuery = [PFUser query];
        
        [userQuery whereKey:kconnectionId equalTo:[[PFUser currentUser] objectForKey:kconnectionId]];
        
        [userQuery whereKey:kfbId notEqualTo:[[PFUser currentUser] objectForKey:kfbId]];
        
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[object objectForKey:kname] forKey:knameconnectedto];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:[object objectForKey:kgender] forKey:kgender];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            PFFile *file=[object objectForKey:kprofilePicture];
            
            strImgurl=file.url;
            
            PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
            [query setLimit: 1000];
            //        [query orderByDescending:@"createdAt"];
            [query whereKey:kconnectionId equalTo:[[PFUser currentUser] objectForKey:kconnectionId]];//[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                if([objects count]>0) {
                    
                    objTemp = [objects objectAtIndex:[objects count]-1];
                    
                    NSString *strUserId = [objTemp objectForKey:kuserId];
                    
                    NSString *strCurrentUserFBID=[[AppDelegate sharedinstance].objParseUser objectForKey:kfbId];
                    
                    // Logic to compare who was the last sender in the chat to determine the time change
                    
                    if([strUserId isEqualToString:strCurrentUserFBID]) {
                        // Last was me
                        
                        NSDate *date=objTemp.createdAt;
                        [formatter setDateFormat:@"hh:mm a"];
                        
                        NSString *resultString = [formatter stringFromDate:date];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:kChatTimeRow];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        strLastSavedChatObjId=objTemp.objectId;
                    }
                    else {
                        // Last was other one
                        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kChatTimeRow];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                else {
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kChatTimeRow];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                if([objects count]==1) {
                      lblSaySomething.alpha = 0;
                    lblSaySomething.hidden=YES;
                    
                }
                else if([objects count]==0) {
                    lblSaySomething.alpha = 0;
                    [UIView animateWithDuration:1.0 animations:^{
                        lblSaySomething.alpha = 1;
                        lblSaySomething.hidden = NO;

                    }];
                }
                
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                [[AppDelegate sharedinstance]hideLoader];

                prevCount=arrChatObj.count;
                
                [arrChatObj removeAllObjects];
                
                if (!error) {
                    
                    for (PFObject *object in objects){
                       // NSLog(@"Object ID: %@", object.objectId);
                        
                        NSString *strText=[object objectForKey:ktext];
                        NSString *strUserId=[object objectForKey:kuserId];
                        PFFile *image = [object objectForKey:kprofilePicture];
                        
                        NSString *strImageUrl =image.url;
                        
                        NSDate *date=object.createdAt;
                        [formatter setDateFormat:@"hh:mm a"];
                        
                        NSString *resultString = [formatter stringFromDate:date];
                        
                        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:strText,ktext,resultString,kChatTime,strUserId,kuserId,strImageUrl,kprofilePicture, nil];
                        [arrChatObj addObject:dict];
                    }
                    
                    if([arrChatObj count]>0) {
                        //[tblChat setHidden:NO];
                    }
                    else {
                        //  [tblChat setHidden:YES];
                        [self stopTimer];
                    }
                    
                    [tblChat reloadData];
                    
                    if(arrChatObj.count>0) {
                        //if(!stopScrollToRow)
                        {
                            prevCount=arrChatObj.count;
                            
                            [tblChat scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrChatObj.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                            initialOffset=tblChat.contentOffset.y;

                        }
                    }
                }
            }];
            
        }];
    }
    else {
        PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
        [query setLimit: 1000];
        //        [query orderByDescending:@"createdAt"];
        [query whereKey:kconnectionId equalTo:[[PFUser currentUser] objectForKey:kconnectionId]];//[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [[AppDelegate sharedinstance]hideLoader];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];

            if([objects count]>0) {
                
                objTemp = [objects objectAtIndex:[objects count]-1];
                
                NSString *strUserId = [objTemp objectForKey:kuserId];
                
                NSString *strCurrentUserFBID=[[AppDelegate sharedinstance].objParseUser objectForKey:kfbId];
                
                // Logic to compare who was the last sender in the chat to determine the time change
                
                if([strUserId isEqualToString:strCurrentUserFBID]) {
                    // Last was me
                    
                    NSDate *date=objTemp.createdAt;
                    [formatter setDateFormat:@"hh:mm a"];
                    
                    NSString *resultString = [formatter stringFromDate:date];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:kChatTimeRow];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    strLastSavedChatObjId=objTemp.objectId;
                }
                else {
                    // Last was other one
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kChatTimeRow];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kChatTimeRow];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if([objects count]==1) {
                lblSaySomething.alpha = 0;
                lblSaySomething.hidden=YES;
            }
            else if([objects count]==0) {
                lblSaySomething.alpha = 0;
                [UIView animateWithDuration:1.0 animations:^{
                    lblSaySomething.alpha = 1;
                    lblSaySomething.hidden = NO;

                }];
            }
            
            prevCount=arrChatObj.count;
            
            [arrChatObj removeAllObjects];
            
            if (!error) {
                
                for (PFObject *object in objects){
                 //   NSLog(@"Object ID: %@", object.objectId);
                    
                    NSString *strText=[object objectForKey:ktext];
                    NSString *strUserId=[object objectForKey:kuserId];
                    PFFile *image = [object objectForKey:kprofilePicture];
                    
                    NSString *strImageUrl =image.url;
                    
                    NSDate *date=object.createdAt;
                    [formatter setDateFormat:@"hh:mm a"];
                    NSString *resultString = [formatter stringFromDate:date];
                    
                    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:strText,ktext,resultString,kChatTime,strUserId,kuserId,strImageUrl,kprofilePicture, nil];
                    [arrChatObj addObject:dict];
                }
                
                if([arrChatObj count]>0) {
                    //[tblChat setHidden:NO];
                }
                else {
                    //  [tblChat setHidden:YES];
                    [self stopTimer];
                }
                
                [tblChat reloadData];
                
                if(arrChatObj.count>0) {
              //      if(!stopScrollToRow)
                    {
                        prevCount=arrChatObj.count;

                        [tblChat scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrChatObj.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        initialOffset=tblChat.contentOffset.y;

                    }
                }
            }
        }];
    }
}

//-----------------------------------------------------------------------

- (IBAction)action_Topics:(id)sender {
    [self pushTopicsVC];
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}


//-----------------------------------------------------------------------

-(IBAction)ratingPressed:(id)sender {
  
    UIButton *btn=(UIButton*)sender;
    
    if(btn==btnOne) {
        [imgRatingStars setImage:[UIImage imageNamed:@"1star.png"]];
        rateUser=1;
    }
    else if(btn==btnTwo) {
        [imgRatingStars setImage:[UIImage imageNamed:@"2star"]];
        rateUser=2;

    }

    else if(btn==btnThree) {
        [imgRatingStars setImage:[UIImage imageNamed:@"3star"]];
        rateUser=3;

    }

    else if(btn==btnFour) {
        [imgRatingStars setImage:[UIImage imageNamed:@"4star"]];
        rateUser=4;

    }
    else if(btn==btnFive) {
        [imgRatingStars setImage:[UIImage imageNamed:@"5star"]];
        rateUser=5;

    }
}

//-----------------------------------------------------------------------

-(IBAction)hoocPressed:(id)sender {
    
    [viewHooc setUserInteractionEnabled:NO];
    
    [viewHooc setBackgroundColor:RGBCOLOR(255, 167, 167)];
    [viewSkip setBackgroundColor:RGBCOLOR(44, 61, 84)];

    [[AppDelegate sharedinstance] showLoader];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
    [query setLimit: 1000];
    [query whereKey:kobjectId equalTo:[[PFUser currentUser] objectForKey:kconnectionId]];//[[NSUserDefaults standardUserDefaults] objectForKey:kconnectionId]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        NSString *strHoocedByConnection=[[AppDelegate sharedinstance] nullcheck:[object objectForKey:khoocedBy]];
        
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        if([strHoocedByConnection length]>0)
            arrTemp=[[strHoocedByConnection componentsSeparatedByString:@","] mutableCopy];

        if([arrTemp count]>=1) {
            
            // Other user has pressed HOOC, and now I am doing, so we both are HOOCED.
            NSString *strHoocedById = [arrTemp objectAtIndex:0];
            
            NSString *strCurrentlyHoocedWith =[[AppDelegate sharedinstance] nullcheck: [[PFUser currentUser] objectForKey:khoocedWith]];
            
            NSMutableArray *arrTemp1 = [[NSMutableArray alloc] init];
            
            if([strCurrentlyHoocedWith length]>0) {
                arrTemp1 = [[strCurrentlyHoocedWith componentsSeparatedByString:@","] mutableCopy];
            }
            
            [arrTemp1 addObject:strHoocedByConnection];
            arrTemp1 = [arrTemp1 valueForKeyPath:@"@distinctUnionOfObjects.self"];


            NSString *strFinalIds =[[arrTemp1 valueForKey:@"description"] componentsJoinedByString:@","];
            
            [[PFUser currentUser] setObject: strFinalIds forKey:khoocedWith];
            [[PFUser currentUser] saveInBackground];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAreBothConnected];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [arrTemp addObject:[[PFUser currentUser] objectForKey:kfbId]];
            
            arrTemp = [arrTemp valueForKeyPath:@"@distinctUnionOfObjects.self"];

            strFinalIds =[[arrTemp valueForKey:@"description"] componentsJoinedByString:@","];
            
            object[khoocedBy]=strFinalIds;
            [object saveInBackground];
            // Change layout based on it
            
            [[AppDelegate sharedinstance] hideLoader];

//            NSMutableArray *array= [[NSMutableArray alloc] init];
//            
//            array=[[NSUserDefaults standardUserDefaults] objectForKey:kLocalhoocedWith];
//            
//            if(!array) {
//                array= [[NSMutableArray alloc] init];
//            }
//            
//            [array addObject:strHoocedById];
//            
//             [[NSUserDefaults standardUserDefaults] setObject:array forKey:kLocalhoocedWith];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self changeLayoutAsBothConnected];
        }
        else {
            [arrTemp addObject:[[PFUser currentUser] objectForKey:kfbId]];
            
            arrTemp = [arrTemp valueForKeyPath:@"@distinctUnionOfObjects.self"];

            NSString *strFinalIds =[[arrTemp valueForKey:@"description"] componentsJoinedByString:@","];
            
            object[khoocedBy]=strFinalIds;
            [object saveInBackground];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCurrentUserHooced];
        [[NSUserDefaults standardUserDefaults] synchronize];
      
        // Create our Installation query
//        PFQuery *pushQuery = [PFInstallation query];
//        strConnectedFBID=[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId];
//        [pushQuery whereKey:kfbId equalTo:strConnectedFBID];
       // [[AppDelegate sharedinstance] sendPushTo:strConnectedFBID withMessage:kHoocedMessage withNotificationType:kNotificationTypeHooced];
        
        [[AppDelegate sharedinstance] hideLoader];
        
      //  [[AppDelegate sharedinstance] displayMessage:@"Connected user will be notified soon."];

    }];
}

//-----------------------------------------------------------------------

-(IBAction)skipPressed:(id)sender {
    
    [[AppDelegate sharedinstance] hideLoader];
    
    [self stopTimer];
    
    [viewSkip setBackgroundColor:RGBCOLOR(255, 167, 167)];
    [viewHooc setBackgroundColor:RGBCOLOR(44, 61, 84)];

    NSString *strConnectionId= [[PFUser currentUser] objectForKey:kconnectionId];
    NSString *strCurrentUserFBId= [[PFUser currentUser] objectForKey:kfbId];

    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
    [query whereKey:kobjectId equalTo:[[PFUser currentUser] objectForKey:kconnectionId]];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objConn, NSError *error) {

                                     PFObject *object = [objConn objectAtIndex:0];
                                     
                                     [[AppDelegate sharedinstance] hideLoader];

                                     NSString *skippedByConnectedUser=[[AppDelegate sharedinstance] nullcheck:[object objectForKey:kskippedBy]];
                                     strSkippedBy =[[AppDelegate sharedinstance] nullcheck: strSkippedBy];

                                     object[kskippedBy] = strCurrentUserFBId;

                                     if([skippedByConnectedUser length]>0) {
                                         // I was skipped, and now it's my turn, so when I skip, turn the connection to closed status.
                                         [PFObject deleteAllInBackground:objConn];

                                     }
                                     else {
                                         [object saveInBackground];

                                     }
                                     
                                     [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCurrentUserHooced];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     
                                     [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAreBothConnected];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     
                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserHasSkipped];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                     
                                     // Create our Installation query
//                                     PFQuery *pushQuery = [PFInstallation query];
//                                     strConnectedFBID=[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId];
//
//                                     [pushQuery whereKey:kfbId equalTo:strConnectedFBID];

//                                     [[AppDelegate sharedinstance] sendPushTo:strConnectedFBID withMessage:kSkippedMessage withNotificationType:kNotificationTypeSkipped];
                                     
                                     //                                     https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ApplePushService.html#//apple_ref/doc/uid/TP40008194-CH100-SW1
                                     
                                     
                                     [self.view bringSubviewToFront:viewRatings];
                                     [viewRatings setHidden:NO];
                                 }];

    
    // Start connecting new user

}

//-----------------------------------------------------------------------

-(IBAction)submitPressed:(id)sender {
    
    [viewHooc setBackgroundColor:RGBCOLOR(183, 72, 64)];
    [viewSkip setBackgroundColor:RGBCOLOR(44, 61, 84)];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Rating"];
    [query whereKey:kuserId equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId]];
    
    [[AppDelegate sharedinstance] showLoader];
    
    // Retrieve the object by id
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error) {
        
        // Set current (your) connection id to 0 that you are available again
        [[PFUser currentUser] setObject:@"0" forKey:kconnectionId];
        [[PFUser currentUser] saveInBackground];
        newConnection=YES;
        
                                     if(!obj) {
                                         PFObject *objRating = [PFObject objectWithClassName:@"Rating"];
                                         [objRating setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kRandomUserId] forKey:kuserId];
                                         
                                         NSString *strNewUserRatings=[NSString stringWithFormat:@"%.2d",rateUser];
                                         [objRating setObject:strNewUserRatings forKey:kratings];
                                         [objRating saveInBackground];
                                         
                                     }
                                     else  {
                                         float currentRatingAvg=[[obj objectForKey:kratings] floatValue];
                                         
                                         NSString *strNewUserRatings=[NSString stringWithFormat:@"%.2f",(currentRatingAvg+rateUser)/2.0];
                                         
                                         obj[kratings] = strNewUserRatings;
                                         [obj saveInBackground];
                                         
                                         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kisConnected];
                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                         
                                     }
                                     [[AppDelegate sharedinstance] hideLoader];

                                     [viewRatings setHidden:YES];
                                     [self.view sendSubviewToBack:viewRatings];
                              
                                     // Start connecting new user
                                    [[AppDelegate sharedinstance] showLoader];
        
                                    [self startTryingConnecting];
        
    }];

}

//-----------------------------------------------------------------------

-(CGRect)rectForText:(NSString *)text
           usingFont:(UIFont *)font
       boundedBySize:(CGSize)maxSize
{
    if(!text) {
        text=@"";
    }
    
    if(!font) {
        return CGRectZero;
    }
    
    NSAttributedString *attrString =
    [[NSAttributedString alloc] initWithString:text
                                    attributes:@{ NSFontAttributeName:font}];
    
    return [attrString boundingRectWithSize:maxSize
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                    context:nil];
}

//-----------------------------------------------------------------------

-(IBAction)imgTapped:(UIButton*)sender{
    CGPoint center= sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblChat];
    NSIndexPath *indexPath = [tblChat indexPathForRowAtPoint:rootViewPoint];
    
    NSLog(@"%d",indexPath.row);
    
    FriendProfileVC *obj = [[FriendProfileVC alloc] initWithNibName:@"FriendProfileVC" bundle:nil];
    obj.strImageUrl=strImgurl;
    obj.strGender=[[NSUserDefaults standardUserDefaults] objectForKey:kgender];

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

//-----------------------------------------------------------------------

#pragma mark - UIGestureRecognizerDelegate Delegate

//-----------------------------------------------------------------------

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//-----------------------------------------------------------------------

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

-(float) heightForChatViewatIndex :(NSInteger) row {
    
    //BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];
    
    CGSize maximumLabelSize = CGSizeMake(190,9999);
    
    UIFont *font =  [UIFont fontWithName:@"gillsans-light" size:17.f];
    
    NSString *str=[[arrChatObj objectAtIndex:row]objectForKey:ktext];
    
    CGRect titleRect = [self rectForText:str
                               usingFont:font
                           boundedBySize:maximumLabelSize];
    
    float h1=titleRect.size.height;
    
    if(h1<20) {
        h1+=5;
    }
    font =  [UIFont fontWithName:@"gillsans-light" size:10.f];
    
    str=[[arrChatObj objectAtIndex:row]objectForKey:kChatTime];
    maximumLabelSize = CGSizeMake(60,9999);
    
    titleRect = [self rectForText:str
                        usingFont:font
                    boundedBySize:maximumLabelSize];
    float h2=titleRect.size.height;

    return h1+h2+20.f;
    
    
}

//-----------------------------------------------------------------------

#pragma mark - TableView Delegate

//-----------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//-----------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    int maxW;
    BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];

    if(bothHooced) {
        maxW=190;
    }
    else {
        maxW=kMaxW;
    }
    
    CGSize maximumLabelSize = CGSizeMake(kMaxW,9999);

    UIFont *font =  [UIFont fontWithName:@"gillsans-light" size:17.f];

    NSString *str=[[arrChatObj objectAtIndex:indexPath.row]objectForKey:ktext];
   
    CGRect titleRect = [self rectForText:str
                               usingFont:font
                           boundedBySize:maximumLabelSize];
    
    float height= titleRect.size.height;
    float height2= titleRect.size.height;

    if(indexPath.row==arrChatObj.count-2) {
        NSLog(@"height %f",height);
    }
    
    if(height>20) {
        if(bothHooced) {
            height+=10;
        }
        else {
            height+=5;

        }
    }
    else
    {
        height+=5;

    }
    
    float height1=height;
    
    font =  [UIFont fontWithName:@"gillsans-light" size:10.f];
    
    str=[[arrChatObj objectAtIndex:indexPath.row]objectForKey:kChatTime];
    maximumLabelSize = CGSizeMake(60,9999);
    
    titleRect = [self rectForText:str
                               usingFont:font
                           boundedBySize:maximumLabelSize];
    
    height=height +  titleRect.size.height;

    bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];

    if(bothHooced) {
        height+=30;

        NSString *strCurrentUserFBID=[[AppDelegate sharedinstance].objParseUser objectForKey:kfbId];
        
        NSString *strChatUserId=[[arrChatObj objectAtIndex:indexPath.row] objectForKey:kuserId];

        if([strChatUserId isEqualToString:strCurrentUserFBID]) {
            
            if((indexPath.row+1)<=arrChatObj.count-1) {
                strChatUserId=[[arrChatObj objectAtIndex:indexPath.row+1] objectForKey:kuserId];

                if(![strChatUserId isEqualToString:strCurrentUserFBID]) {
                    height2 = height2 + ((height2*80.f)/100.f);
                    height2 = height2 + 30;
                    height = height2;
                }
                else {
                    

                }
            }
        }
        

//        if(height1<20) {
//            height+=40;
//        }
//        else {
//            height+=40;
//        }
    }
    else {
        height+=5;
    }
    
//    if(([strTimeChange length]==0) || (![strTimeChange isEqualToString:str])) {
//        // Time has changed, so show time
//        height=height +  15;
//        strTimeChange=str;
//    }
//    else {
//        height=height +  7;
//    }
    
    NSLog(@"==================================================");
    NSLog(@"height for row  %f",height);
    NSLog(@"==================================================");
    
    if(bothHooced) {
        return [self heightForChatViewatIndex:indexPath.row];
    }
    
    return height;
}

//-----------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return arrChatObj.count;
}

//-----------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell_Chat *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_Chat"];
    
  // if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_Chat" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];

//    cell.lblChatText.layer.borderColor=[UIColor blackColor].CGColor;
//    cell.lblChatText.layer.borderWidth=1.f;
//    
//    cell.lblChatTime.layer.borderColor=[UIColor blackColor].CGColor;
//    cell.lblChatTime.layer.borderWidth=1.f;
//    
//    cell.lblRightChatText.layer.borderColor=[UIColor redColor].CGColor;
//    cell.lblRightChatText.layer.borderWidth=1.f;
//    
//    cell.lblRightChatTime.layer.borderColor=[UIColor redColor].CGColor;
//    cell.lblRightChatTime.layer.borderWidth=1.f;
//    
//    cell.leftChatView.layer.borderColor=[UIColor darkGrayColor].CGColor;
//    cell.leftChatView.layer.borderWidth=1.f;
//    
//    cell.rightChatView.layer.borderColor=[UIColor purpleColor].CGColor;
//   cell.rightChatView.layer.borderWidth=1.f;
    
//    for(UIView *view in [cell.contentView subviews]) {
//        [[AppDelegate sharedinstance] applyCustomFontToView:view];
//    }
    
    NSDictionary *obj=[arrChatObj objectAtIndex:indexPath.row];
    NSString *strChatText=[obj objectForKey:ktext];
    NSString *strChatUserId=[obj objectForKey:kuserId];
    NSString *strChatTime=[obj objectForKey:kChatTime];
    
    NSString *strImageUrl=[obj objectForKey:kprofilePicture];

    NSString *strCurrentUserFBID=[[AppDelegate sharedinstance].objParseUser objectForKey:kfbId];

    if(![strChatUserId isEqualToString:strCurrentUserFBID]) {
        // other user
        [cell.leftChatView setHidden:NO];
        [cell.rightChatView setHidden:YES];
        
        cell.imgViewLeft.clipsToBounds=YES;
        cell.imgViewLeft.layer.cornerRadius=cell.imgViewLeft.frame.size.height/2;
        cell.imgViewLeft.layer.borderWidth=0;
         cell.imgViewLeft.layer.borderColor=[UIColor clearColor].CGColor;

        cell.imgViewRight.layer.borderWidth=0;
        cell.imgViewRight.layer.borderColor=[UIColor clearColor].CGColor;
        
        UIFont *font =  [UIFont fontWithName:@"gillsans-light" size:17.f];
        [cell.lblChatText setFont:font];
        
        font =  [UIFont fontWithName:@"gillsans-light" size:10.f];
        [cell.lblChatTime setFont:font];
        
        [cell.lblChatTime setText:strChatTime];
        
        [cell.lblChatText setText:strChatText];
        
        [cell.lblChatText setTextAlignment:NSTextAlignmentLeft];
        
//        cell.lblChatText.layer.borderColor=[UIColor blackColor].CGColor;
//        cell.lblChatText.layer.borderWidth=1.f;
        
        int maxW=0;
        
        if(bothHooced) {
            maxW=190;
        }
        else {
            maxW=kMaxW;
        }
        
        CGSize maximumLabelSize = CGSizeMake(maxW,9999);
        
        font =  cell.lblChatText.font;
        
        NSString *str=[[arrChatObj objectAtIndex:indexPath.row] objectForKey:ktext];
        
        font =  [UIFont fontWithName:@"gillsans-light" size:17.f];

        CGRect titleRect1 = [self rectForText:str
                                    usingFont:font
                                boundedBySize:maximumLabelSize];
        
       cell.lblChatText.frame=titleRect1;
        
        font =  [UIFont fontWithName:@"gillsans-light" size:10.f];
        str=[[arrChatObj objectAtIndex:indexPath.row] objectForKey:kChatTime];
        maximumLabelSize = CGSizeMake(60,9999);
        
        titleRect1 = [self rectForText:str
                             usingFont:font
                         boundedBySize:maximumLabelSize];
        
        titleRect1.origin.y=cell.lblChatText.frame.size.height-10;
        
        titleRect1.origin.x=cell.lblChatText.frame.origin.x + cell.lblChatText.frame.size.width + 13;
        
        if(bothHooced)
            titleRect1.origin.x= titleRect1.origin.x+50;
        
        titleRect1.size.width=60;
        titleRect1.size.height=17;
        
        cell.lblChatTime.frame=titleRect1;
        
        CGRect frame = cell.lblChatText.frame;
        
        if(bothHooced) {
            
            frame.origin.x=62;
            frame.origin.y = frame.origin.y + 15;
            cell.lblChatText.frame=frame;
            
             frame = cell.lblChatTime.frame;
            frame.origin.y = frame.origin.y + 15;
            cell.lblChatTime.frame=frame;

        }
        else
        {
            frame.origin.x=13;
          cell.lblChatText.frame=frame;
        }
        
        frame = cell.leftChatView.frame;
        
        if(bothHooced) {
            frame.size.height=cell.lblChatText.frame.size.height+25;
        }
        else {
            frame.size.height=cell.lblChatText.frame.size.height+5;
        }
        
        cell.leftChatView.frame=frame;
        
//        if(([strTimeChangeRow length]==0) || (![strTimeChangeRow isEqualToString:strChatTime])) {
//            strTimeChangeRow=strChatTime;
//            [cell.lblChatTime setHidden:NO];
//        }
//        else {
//            [cell.lblChatTime setHidden:YES];
//
//        }

    }
    else {
        // Myself

        [cell.leftChatView setHidden:YES];
        [cell.rightChatView setHidden:NO];

        cell.imgViewRight.image=[[AppDelegate sharedinstance] getImage:klocalPic];

        cell.imgViewRight.clipsToBounds=YES;
        cell.imgViewRight.layer.cornerRadius=cell.imgViewRight.frame.size.height/2;
        
        UIFont *font =  [UIFont fontWithName:@"gillsans-light" size:17.f];
        [cell.lblRightChatText setFont:font];
        
        font =  [UIFont fontWithName:@"gillsans-light" size:10.f];
        [cell.lblRightChatTime setFont:font];
        
        [cell.lblRightChatTime setText:strChatTime];

        [cell.lblRightChatText setText:strChatText];

        int maxW=0;
        
        if(bothHooced) {
            maxW=190;
        }
        else {
            maxW=kMaxW;
        }
        
        CGSize maximumLabelSize = CGSizeMake(maxW,9999);
        
        font =  [UIFont fontWithName:@"gillsans-light" size:17.f];

        NSString *str=[[arrChatObj objectAtIndex:indexPath.row] objectForKey:ktext];
        
        CGRect titleRect1 = [self rectForText:str
                                    usingFont:font
                                boundedBySize:maximumLabelSize];
        
        float h2=0;
        
        if(bothHooced) {
            if(titleRect1.size.height<20) {
                h2=5;
                titleRect1.origin.y=titleRect1.origin.y-40;
            }
        }
   
        titleRect1.size.height=titleRect1.size.height + h2;
        
        cell.lblRightChatText.frame=titleRect1;

        str=[[arrChatObj objectAtIndex:indexPath.row] objectForKey:kChatTime];
        
        font =  [UIFont fontWithName:@"gillsans-light" size:10.f];
        maximumLabelSize = CGSizeMake(60,9999);
        
        CGRect frame = cell.lblRightChatText.frame;
        
        if(indexPath.row==0) {
            NSLog(@"%f",cell.lblRightChatText.frame.size.height);
        }
        
        if(bothHooced) {
             frame.origin.x=320-frame.size.width-65;
            frame.origin.y=18;
             cell.lblRightChatText.frame=frame;
        }
        else
        {
            frame.origin.x=320-frame.size.width-15;
            cell.lblRightChatText.frame=frame;
        }
        
        titleRect1 = [self rectForText:str
                             usingFont:font
                         boundedBySize:maximumLabelSize];

        if(bothHooced) {
            titleRect1.origin.y=cell.lblRightChatText.frame.size.height;
        }
        else {
            titleRect1.origin.y=cell.lblRightChatText.frame.size.height-10;
        }

//        if(cell.lblRightChatText.frame.size.height<20) {
//            if(bothHooced) {
//                titleRect1.origin.y= titleRect1.origin.y + 30;
//            }
//        }
        
        CGRect titleRect2 = cell.lblRightChatTime.frame;
        titleRect2.origin.y = titleRect1.origin.y + 7;
        titleRect2.origin.x= cell.lblRightChatText.frame.origin.x - 60;
        titleRect2.size.width=60;
        titleRect2.size.height=17;
        cell.lblRightChatTime.frame=titleRect2;

        frame = cell.rightChatView.frame;
        
        if(bothHooced) {
            frame.size.height=cell.lblRightChatText.frame.size.height+32;
            
            if(cell.lblRightChatText.frame.size.height<20) {
                frame.size.height= frame.size.height+25;
                
          
            }
        }
        else {
            frame.size.height=cell.lblRightChatText.frame.size.height+5;
        }
        
        cell.rightChatView.frame=frame;

    }
    
    if(bothHooced) {
        
        [cell.imgViewLeft setImageWithURL:[NSURL URLWithString:strImgurl] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        cell.imgViewRight.image=[[AppDelegate sharedinstance] getImage:klocalPic];

        [cell.imgViewLeft setHidden:NO];
        [cell.imgViewRight setHidden:NO];
    }
    else {
        
        [cell.imgViewLeft setHidden:YES];
        [cell.imgViewRight setHidden:YES];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
   
    float h3=[self heightForChatViewatIndex:indexPath.row];
    
    if(![strChatUserId isEqualToString:strCurrentUserFBID]) {
        
       CGRect frame = cell.leftChatView.frame;
        if(bothHooced) {
          //  frame.size.height=cell.lblChatText.frame.size.height + cell.lblChatTime.frame.size.height + 20;
            frame.size.height=h3;
        }
        else {
            frame.size.height=cell.lblChatText.frame.size.height + cell.lblChatTime.frame.size.height;// + 20;

        }
        cell.leftChatView.frame=frame;
    }
    else {
        CGRect frame = cell.rightChatView.frame;
        
        if(bothHooced) {
           // frame.size.height=cell.lblRightChatText.frame.size.height + cell.lblRightChatTime.frame.size.height+ 20;
            frame.size.height=h3;

        }
        else {
            frame.size.height=cell.lblRightChatText.frame.size.height + cell.lblRightChatTime.frame.size.height;// + 20;
        }
        cell.rightChatView.frame=frame;
    }
    
//    NSLog(@"==================================================");
//    
//    NSLog(@"Frame info chatText %@\n chatTime %@\n ViewRight  %@\n",NSStringFromCGRect(cell.lblRightChatText.frame),NSStringFromCGRect(cell.lblRightChatTime.frame),NSStringFromCGRect(cell.rightChatView.frame));
//    
//    NSLog(@"==================================================");
    return cell;
}

//-----------------------------------------------------------------------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

//-----------------------------------------------------------------------

#pragma mark - Scrollview Delegate

//-----------------------------------------------------------------------

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    stopScrollToRow=YES;
}

//-----------------------------------------------------------------------

-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    float newscrollOffset = scrollView.contentOffset.y;
    
    if(initialOffset==0) {
        
    }
    
    if(newscrollOffset<(initialOffset-50)) {
        stopScrollToRow=YES;
        NSLog(@"NOT  call reload to bottom");
        [self stopTimer];

    }
    else {
//        NSLog(@" ================================ \n'");
//
//        NSLog(@"newscrollOffset %f initialoffset %f",newscrollOffset,initialOffset);
//        
//       NSLog(@" ================================ \n'");
        
        [self startTimer];
        
        stopScrollToRow=NO;
        NSLog(@"Will call reload to bottom");
    }
}

//-----------------------------------------------------------------------

#pragma mark - THChatInputDelegate

//-----------------------------------------------------------------------

- (void)chat:(THChatInput*)input sendWasPressed:(NSString*)text
{
    
    if([text length]==0)
    {
        [[AppDelegate sharedinstance] displayMessage:@"Text cannot be empty"];

        return;
    }
    strMessage=input.text;
    
    [self sendMessage];

   // _textView.text = text;
    [chatInput setText:@""];
    [chatInput resignFirstResponder];
    
    [self.view makeToast:@"Sending your message"
                duration:1.0
                position:CSToastPositionCenter];
}

//-----------------------------------------------------------------------

-(void)chatKeyboardWillShow:(THChatInput*)cinput {
    stopScrollToRow=NO;
    
    BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];
    tempFrame.origin.y=68;
    tempFrame.size.height=239;

    if(bothHooced || (countMutualFriends==0)) {
        [tblChat setFrame:tempFrame];
        
    }
    else {
        [tblChat setFrame:tempFrame];
    }

  //  tblChat.frame= CGRectMake(tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.width,197);
    
    if(arrChatObj.count>0) {
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:arrChatObj.count-1 inSection:0];
        
        [tblChat scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        initialOffset=tblChat.contentOffset.y;
    }
    
}

//-----------------------------------------------------------------------

- (void)chatKeyboardWillHide:(THChatInput*)cinput {

    BOOL bothHooced=[[NSUserDefaults standardUserDefaults] boolForKey:kAreBothConnected];
    tempFrame.origin.y=68;
    tempFrame.size.height=415;

    if(bothHooced || (countMutualFriends==0)) {
//        tempFrame.origin.y=62;
//        tempFrame.size.height=430;
//        [tblChat setFrame:tempFrame];

    }
    else {
      //  tempFrame.origin.y=125;
        [tblChat setFrame:tempFrame];
    }
    
    tblChat.frame=tempFrame;
}

@end
