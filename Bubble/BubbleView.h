//
//  BubbleView.h
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BubbleView : UIView
@property (strong, nonatomic) NSString *bubbleColor;
@property (nonatomic) BOOL chosen;
@property (nonatomic) BOOL empty;
+ (NSDictionary *)bubbleColorDict;
@end
