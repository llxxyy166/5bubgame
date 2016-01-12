//
//  ScoreBarView.m
//  Bubble
//
//  Created by xinye lei on 16/1/4.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

#import "ScoreBarView.h"
#import "BubbleView.h"
#import "BubblePiece.h"
@implementation ScoreBarView

- (void)setScore:(NSUInteger)score {
    _score = score;
    [self setNeedsDisplay];
}

- (void)setTopScore:(NSUInteger)topScore {
    _topScore = topScore;
    [self setNeedsDisplay];
}

- (void)setDisplayColor:(NSString *)displayColor {
    _displayColor = displayColor;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *path = [[UIBezierPath alloc] init];
    double ratio;
    if (self.topScore) {
        ratio = (double) self.score / self.topScore;
    }
    else {
        ratio = 0;
    }
    NSString *colorString = [[BubblePiece validColor] objectAtIndex: arc4random() % [[BubblePiece validColor] count]];
    UIColor *color;
    if (!self.displayColor) {
        color = [UIColor clearColor];
    }
    else {
        if ([self.displayColor isEqualToString:@"allColor"]) {
            color = [BubbleView bubbleColorDict][colorString];
        }
        else {
            color = [BubbleView bubbleColorDict][self.displayColor];
        }
    }
    CGPoint orgin = self.bounds.origin;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint point = CGPointMake(orgin.x + ratio * width, orgin.y);
    [path moveToPoint:orgin];
    [path addLineToPoint:point];
    [path addLineToPoint:CGPointMake(point.x, orgin.y)];
    [path addLineToPoint:CGPointMake(point.x, orgin.y + height)];
    [path addLineToPoint:CGPointMake(orgin.x, orgin.y + height)];
    [path closePath];
    [color setStroke];
    [color setFill];
    [path stroke];
    [path fill];
}


@end
