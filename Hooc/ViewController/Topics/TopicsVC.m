//
//  ViewController.m
//  Hooc
//
//  Created by Amolaksingh on 01/11/15.
//  Copyright © 2015 Hooc. All rights reserved.
//

#import "TopicsVC.h"
#import "EditProfileVC.h"
#import "cell_TopicsVC.h"

#define kHot 1
#define kLatest 2

@interface TopicsVC ()

@end

@implementation TopicsVC

//-----------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    arrTopics=[[NSMutableArray alloc] init];
    arrObjId=[[NSMutableArray alloc] init];

    getTopicsBy=kHot;
    
    [lblNoTopics setHidden:YES];
    
    [self setInitialSettings];
    [self addGestures];

}

//-----------------------------------------------------------------------

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.menuContainerViewController.panMode=NO;

    [self getTopicObjBy:getTopicsBy];
    
}

//-----------------------------------------------------------------------

-(void)viewWillDisAppear:(BOOL)animated{
    
}

//-----------------------------------------------------------------------

#pragma mark Custom Method

//-----------------------------------------------------------------------

-(void) setInitialSettings {
    [viewHot setBackgroundColor:RGBCOLOR(255, 167, 167)];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    for(UIView *view in [self.view subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
    
    viewPost.clipsToBounds=YES;
    viewPost.layer.cornerRadius=viewPost.frame.size.height/2;
    viewPost.layer.borderColor=[UIColor clearColor].CGColor;
}

//-----------------------------------------------------------------------

-(void) addGestures {
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    recognizer.numberOfTouchesRequired = 1;
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];

}


//-----------------------------------------------------------------------

-(void)swipeHandler:(UISwipeGestureRecognizer *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

//-----------------------------------------------------------------------

-(void) getTopicObjBy:(int) status{
    [arrTopics removeAllObjects];
    [arrObjId removeAllObjects];
    
    [[AppDelegate sharedinstance]showLoader];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Topics"];
    [query setLimit: 1000];
    
    if(status==kHot) {
        [query orderByDescending:@"likes"];
    }
    else {
        [query orderByDescending:@"createdAt"];
        
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[AppDelegate sharedinstance]hideLoader];
        
        if (!error) {
            
            for (PFObject *object in objects){
                NSLog(@"Object ID: %@", object.objectId);
                
                [arrObjId addObject:object.objectId];
                
                [arrTopics addObject:object];
            }
            
            // The find succeeded. Add the returned objects to allObjects
        }
        
        [tblTopics reloadData];
    }];
}

//-----------------------------------------------------------------------

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"ico_menu"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(action_Menu:)];
}

//-----------------------------------------------------------------------

- (void)setupMenuBarButtonItems {
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//-----------------------------------------------------------------------

-(IBAction)hotPressed:(id)sender {
    [viewHot setBackgroundColor:RGBCOLOR(255, 167, 167)];
    [viewLatest setBackgroundColor:RGBCOLOR(44, 61, 84)];
    getTopicsBy=kHot;

    [self getTopicObjBy:getTopicsBy];
}

//-----------------------------------------------------------------------

-(IBAction)latestPressed:(id)sender {
    [viewLatest setBackgroundColor:RGBCOLOR(154, 164, 174)];
    [viewHot setBackgroundColor:RGBCOLOR(183, 72, 64)];
    getTopicsBy=kLatest;

    [self getTopicObjBy:getTopicsBy];
}

//-----------------------------------------------------------------------

-(IBAction)likesPressed:(UIButton*)sender {
    
    CGPoint center=sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblTopics];
    NSIndexPath *indexPath = [tblTopics indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"%d",indexPath.row);
    
    PFObject *dictTopic=(PFObject*)[arrTopics objectAtIndex:indexPath.row];
    
    NSString *strLikedBy=[[AppDelegate sharedinstance] nullcheck:dictTopic[klikedBy]];
    NSString *strEmail=[[AppDelegate sharedinstance].dictUserDetail objectForKey:@"email"] ;
    __block int likes=[[dictTopic objectForKey:klikes] intValue];

    PFQuery *query = [PFQuery queryWithClassName:@"Topics"];
    [[AppDelegate sharedinstance] showLoader];

    NSString *strObjId=[arrObjId objectAtIndex:indexPath.row];
    
     [query getObjectInBackgroundWithId:strObjId block:^(PFObject *post, NSError *error) {

         NSMutableArray *arrTemp=[[NSMutableArray alloc] init];
         
         arrTemp = [[strLikedBy componentsSeparatedByString:@","] mutableCopy];
         
         if([self hasLiked:strLikedBy byEmail:strEmail]) {
             // Was liked, so make unlike
             likes=likes-1;
             
             [arrTemp removeObject:strEmail];
         }
         else {
             // Was Unliked, so make like
             likes=likes+1;
             
             [arrTemp addObject:strEmail];
         }
         
         post[klikes] =[NSNumber numberWithInt:likes];
         
         post[klikedBy]= [[arrTemp valueForKey:@"description"] componentsJoinedByString:@","];

         [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             
             if (succeeded) {
                 
                 // The object has been saved.
                 
                 [self getTopicObjBy:getTopicsBy];
                 
                 [txtViewTopics resignFirstResponder];
                 
             } else {
                 // There was a problem, check error.description
             }
         }];
    }];
    

}

//-----------------------------------------------------------------------

-(IBAction)postPressed:(id)sender {
    NSLog(@"%@\n",txtViewTopics.text);
    
  NSString *str=[[AppDelegate sharedinstance] nullcheck: txtViewTopics.text];
   
    if([str length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Topic cannot be empty"];
        return;
    }
    
    [self post];
}

//-----------------------------------------------------------------------

-(void) post {
    PFObject *post = [PFObject objectWithClassName:@"Topics"];
    post[klikes] =[NSNumber numberWithInt:0];
    post[ktext] =txtViewTopics.text;
    txtViewTopics.text=@"";

    [[AppDelegate sharedinstance] showLoader];
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            [lblCountChars setText:@"70"];
            
            // The object has been saved.
            
            [self getTopicObjBy:getTopicsBy];
            
            [lblPlaceholder setHidden:NO];
            
            [txtViewTopics resignFirstResponder];
            
        } else {
            // There was a problem, check error.description
        }
    }];

}

//-----------------------------------------------------------------------

-(BOOL) hasLiked:(NSString *)strLikedBy byEmail:(NSString*)strEmail  {
    if([strLikedBy length]==0) {
      //  [cell.btnLike setImage:[UIImage imageNamed:@"fire-off"] forState:UIControlStateNormal];
        return NO;

    }
    else {
        NSArray *arrTemp = [strLikedBy componentsSeparatedByString:@","];
        
        BOOL isTheObjectThere = [arrTemp containsObject: strEmail];
        return isTheObjectThere;
    }
    return YES;
}

//-----------------------------------------------------------------------

#pragma mark - UITextView Delegate

//-----------------------------------------------------------------------

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    txtViewTopics.text=@"";
    [lblPlaceholder setHidden:YES];
    
    return YES;
}

//-----------------------------------------------------------------------

-(void) textViewDidBeginEditing:(UITextView *)textView {
    
    
}

//-----------------------------------------------------------------------

- (void)textViewDidEndEditing:(UITextView *)textView{
    //[lblPlaceholder setHidden:NO];

}

//-----------------------------------------------------------------------

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    int count=textView.text.length + (text.length - range.length);
    [lblCountChars setText:[NSString stringWithFormat:@"%d",71-count]];
 
    if([text isEqualToString:@"\n"])
    {
        [txtViewTopics resignFirstResponder];
        
//        [self performSelector:@selector(post) withObject:nil afterDelay:.3];

        return NO;
    }
    
    if(count <= 70) {
        return YES;
    }
    
    return NO;
}

//-----------------------------------------------------------------------

#pragma mark - TableView Delegate

//-----------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//-----------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66;
}

//-----------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(arrTopics.count==0) {
        [lblNoTopics setHidden:NO];
    }
    else {
        [lblNoTopics setHidden:YES];
    }
    
    return arrTopics.count;
}

//-----------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell_TopicsVC *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_TopicsVC"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_TopicsVC" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    for(UIView *view in [cell.contentView subviews]) {
        [[AppDelegate sharedinstance] applyCustomFontToView:view];
    }
 
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    NSDictionary *dictTopics=[arrTopics objectAtIndex:indexPath.row];
    [cell.lblTopics setText:[dictTopics objectForKey:ktext]];
    [cell.lblLikes setText:[NSString stringWithFormat:@"%@",[dictTopics objectForKey:klikes]]];

    NSString *strLikedBy=[[AppDelegate sharedinstance] nullcheck:[dictTopics objectForKey:klikedBy]];
    NSString *strEmail=[[AppDelegate sharedinstance].dictUserDetail objectForKey:@"email"] ;

    if([self hasLiked:strLikedBy byEmail:strEmail]) {
        [cell.btnLike setImage:[UIImage imageNamed:@"fire-on"] forState:UIControlStateNormal];
    }
    else {
        [cell.btnLike setImage:[UIImage imageNamed:@"fire-off"] forState:UIControlStateNormal];

    }
    
    return cell;
}

//-----------------------------------------------------------------------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dictTopics=[arrTopics objectAtIndex:indexPath.row];
    strTopic=[dictTopics objectForKey:ktext];
    
    [[NSUserDefaults standardUserDefaults] setObject:strTopic forKey:ktext];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//-----------------------------------------------------------------------

//- (IBAction)action_deleteProduct:(UIButton *)sender {
//    CGPoint center= sender.center;
//
//    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tbl_MyDreamList];
//    NSIndexPath *indexPath = [self.tbl_MyDreamList indexPathForRowAtPoint:rootViewPoint];
//    NSLog(@"%d",indexPath.row);
//
//    indexToDel=indexPath.row;
//
//    UIAlertView  *alert_Delete=[[UIAlertView alloc] initWithTitle:kAppName message:@"Are you sure to delete?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//    [alert_Delete setTag:201];
//    [alert_Delete show];
//
//}

@end
