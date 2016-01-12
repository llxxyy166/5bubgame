//
//  BubblePiece.h
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct position {
    NSInteger row;
    NSInteger column;
}position;

@interface BubblePiece : NSObject

@property (strong, nonatomic) NSString *bubbleColor;
@property (nonatomic) BOOL empty;
@property (nonatomic) position currentPosition;
- (instancetype)initWithColor: (NSString *)bubbleColor;
+ (NSArray *)validColor;
@end
