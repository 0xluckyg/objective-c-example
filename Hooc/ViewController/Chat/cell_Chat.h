//
//  cell_MyDream.h
//  DIBS
//
//  Created by Admin on 01/03/15.
//  Copyright (c) 2015 task. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cell_Chat : UITableViewCell {
    IBOutlet UILabel *lblChatText;
    IBOutlet UILabel *lblChatTime;
    IBOutlet UIImageView *imgViewLeft;
    
    IBOutlet UILabel *lblRightChatText;
    IBOutlet UILabel *lblRightChatTime;
    IBOutlet UIImageView *imgViewRight;
    
    IBOutlet UIView *leftChatView,*rightChatView;
}

@property (nonatomic,strong)   IBOutlet UILabel *lblChatText;
@property (nonatomic,strong)   IBOutlet UILabel *lblChatTime;
@property (nonatomic,strong)   IBOutlet  UIImageView *imgViewLeft;

@property (nonatomic,strong)   IBOutlet UILabel *lblRightChatText;
@property (nonatomic,strong)   IBOutlet UILabel *lblRightChatTime;
@property (nonatomic,strong)   IBOutlet  UIImageView *imgViewRight;

@property (nonatomic,strong) IBOutlet UIView *leftChatView,*rightChatView;

@end
