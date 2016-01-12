//
//  BubbleView.m
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import "BubbleView.h"

@implementation BubbleView

- (void)setChosen:(BOOL)chosen {
    _chosen = chosen;
    [self setNeedsDisplay];
}

- (void)setBubbleColor:(NSString *)bubbleColor {
    _bubbleColor = bubbleColor;
    [self setNeedsDisplay];
}

- (void)setEmpty:(BOOL)empty {
    _empty = empty;
    [self setNeedsDisplay];
}

+ (NSDictionary *)bubbleColorDict {
    return @{@"redColor": [UIColor redColor],@"blueColor": [UIColor blueColor], @"greenColor": [UIColor greenColor], @"purpleColor": [UIColor purpleColor], @"yellowColor": [UIColor yellowColor], @"grayColor": [UIColor grayColor], @"orangeColor": [UIColor orangeColor]};
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGPoint center;
    center.x = self.bounds.origin.x + self.bounds.size.width / 2;
    center.y = self.bounds.origin.y + self.bounds.size.height / 2;
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height);
    radius = radius / 2.2;
    if (!self.empty) {
        if ([self.bubbleColor isEqualToString:@"allColor"]) {
            CGFloat currentAngle = 0;
            NSUInteger colorNumber = [[BubbleView bubbleColorDict] count];
            CGFloat anglePerColor = (CGFloat) 2 * M_PI / colorNumber;
            NSArray *allKeys = [[BubbleView bubbleColorDict] allKeys];
            for (NSString *string in allKeys) {
                UIBezierPath *subPath = [[UIBezierPath alloc] init];
                [[UIColor clearColor] setStroke];
                if (self.chosen) {
                    subPath.lineWidth = radius / 20;
                    [[UIColor blackColor] setStroke];
                }
                [subPath moveToPoint:center];
                UIColor *color = [BubbleView bubbleColorDict][string];
                [subPath addArcWithCenter:center radius:radius startAngle:currentAngle endAngle:currentAngle + anglePerColor clockwise:YES];
                currentAngle += anglePerColor;
                [subPath closePath];
                [color setFill];
                [subPath fill];
                [subPath stroke];
            }
        }
        else {
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path addArcWithCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
            UIColor *color = [[BubbleView bubbleColorDict] objectForKey:self.bubbleColor];
            [color setStroke];
            [color setFill];
            if (self.chosen) {
                path.lineWidth = radius / 9;
                [[UIColor blackColor] setStroke];
            }
            [path stroke];
            [path fill];
        }
    }
    else {
        UIColor *color = [BubbleView bubbleColorDict][self.bubbleColor];
        UIBezierPath *outCircle = [[UIBezierPath alloc] init];
        [outCircle addArcWithCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
        UIBezierPath *inCircle = [[UIBezierPath alloc] init];
        [inCircle addArcWithCenter:center radius:radius / 1.5 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        UIColor *hollowColor = [self superview].backgroundColor;
        [color setStroke];
        [color setFill];
        if (self.chosen) {
            outCircle.lineWidth = radius / 9;
            [[UIColor blackColor] setStroke];
        }
        [outCircle fill];
        [outCircle stroke];
        [hollowColor setFill];
        [inCircle fill];
    }
}


@end
