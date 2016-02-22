//
//  ViewController.h
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface TopicsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextView *txtViewTopics;

    IBOutlet UIView *viewPost;
    IBOutlet UIView *viewHot;
    IBOutlet UIView *viewLatest;

    IBOutlet UITableView *tblTopics;
    IBOutlet UILabel *lblNoTopics;
    IBOutlet UILabel *lblPlaceholder;

    IBOutlet UILabel *lblCountChars;
    
    NSMutableArray *arrTopics;
    int getTopicsBy;
    NSMutableArray *arrObjId;
    NSString *strTopic;

}

-(IBAction)hotPressed:(id)sender;
-(IBAction)latestPressed:(id)sender;
-(IBAction)likesPressed:(id)sender;
-(IBAction)postPressed:(id)sender;

@end

