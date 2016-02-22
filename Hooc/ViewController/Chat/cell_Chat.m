//
//  cell_MyDream.m
//  DIBS
//
//  Created by Admin on 01/03/15.
//  Copyright (c) 2015 task. All rights reserved.
//

#import "cell_Chat.h"

@implementation cell_Chat
@synthesize imgViewLeft;
@synthesize lblChatTime;

@synthesize lblRightChatText;
@synthesize imgViewRight;
@synthesize lblRightChatTime;
@synthesize rightChatView;
@synthesize leftChatView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
