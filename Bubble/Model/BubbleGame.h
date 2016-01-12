//
//  BubbleGame.h
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubblePiece.h"

@interface BubbleGame : NSObject

@property (strong, nonatomic) NSMutableArray *gameBoard;
@property (readonly) NSUInteger score;
@property (strong, nonatomic) NSArray *nextTurnBubbles;
@property (nonatomic) BOOL advancedMode;
@property (nonatomic) NSInteger bubbleNumber;
- (instancetype)initWithOption: (BOOL)advancedMode;
- (NSUInteger)getTopScoreWithAdvancedMode: (BOOL)advancedMode;
- (id)choseCellAtPosition: (position)position;
- (void)addBubble: (BubblePiece *)bubble;
- (NSArray *)moveBubbleFrom: (position)originPosition
                    to: (position)destinationPosition;
- (void)setTopScore: (NSInteger)score
       advancedMode: (BOOL)advancedMode;

@end
