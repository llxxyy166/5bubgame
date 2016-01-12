//
//  gameBoardView.m
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import "gameBoardView.h"

@implementation gameBoardView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint origin = self.bounds.origin;
    CGFloat width = self.bounds.size.width / 10;
    CGFloat height = self.bounds.size.height / 10;
    for (CGFloat pos = origin.x; pos <= origin.x + self.bounds.size.width; pos += width) {
        CGPoint p1 = CGPointMake(pos, origin.y);
        CGPoint p2 = CGPointMake(pos, origin.y + self.bounds.size.height);
        [path moveToPoint:p1];
        [path addLineToPoint:p2];
    }
    for (CGFloat pos = origin.y; pos <= origin.y +self.bounds.size.height; pos += height) {
        CGPoint p1 = CGPointMake(origin.x, pos);
        CGPoint p2 = CGPointMake(origin.x + self.bounds.size.width, pos);
        [path moveToPoint:p1];
        [path addLineToPoint:p2];
    }
    [[UIColor blackColor] setStroke];
    [path stroke];
}


@end
