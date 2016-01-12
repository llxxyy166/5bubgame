//
//  BubblePiece.m
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import "BubblePiece.h"

@implementation BubblePiece

+ (NSArray *)validColor {
    return @[@"redColor",@"blueColor",@"greenColor",@"purpleColor", @"yellowColor", @"orangeColor", @"grayColor"];
    //return @[@"grayColor"];
}


- (void)setBubbleColor:(NSString *)bubbleColor {
    _bubbleColor = bubbleColor;
}

- (instancetype)initWithColor: (NSString *)bubbleColor {
    self = [super init];
    if (self) {
        self.bubbleColor = bubbleColor;
    }
    return self;
}
@end
