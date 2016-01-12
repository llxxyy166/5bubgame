//
//  ScoreBarView.h
//  Bubble
//
//  Created by xinye lei on 16/1/4.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreBarView : UIView

@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger topScore;

@property (nonatomic, strong) NSString *displayColor;

@end
