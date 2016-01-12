//
//  BubbleGame.m
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import "BubbleGame.h"


@interface BubbleGame()
@property (strong, nonatomic) NSArray *validBubbleColor;
@property (readwrite) NSUInteger score;
@end

@implementation BubbleGame

- (NSMutableArray *)gameBoard {
    if (!_gameBoard) {
        _gameBoard = [[NSMutableArray alloc] init];
    }
    return _gameBoard;
}

- (NSArray *)nextTurnBubbles {
    if (!_nextTurnBubbles) {
        NSMutableArray *nextTurn = [[NSMutableArray alloc] init];
        for (int i = 0; i < 3; i++) {
            BubblePiece *bubble = [self generateRandomBubble];
            [nextTurn addObject:bubble];
        }
        _nextTurnBubbles = nextTurn;
    }
    return _nextTurnBubbles;
}

- (instancetype)initWithOption: (BOOL)advancedMode {
    self = [super init];
    if (self) {
        self.advancedMode = advancedMode;
        self.score = 0;
        self.bubbleNumber = 0;
        self.validBubbleColor = [BubblePiece validColor];
        for (int i = 0; i < 10; i++) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < 10; i++) {
                [array addObject:[NSString stringWithFormat:@""]];
            }
            [self.gameBoard addObject:array];
        }
        for (int i = 0; i < 6; i++) {
            [self addBubble: [self generateRandomBubble]];
        }
    }
    return self;
}

- (BubblePiece *)generateRandomBubble {
    BubblePiece *newBubble = [[BubblePiece alloc] initWithColor:[self pickRandomBubble]];
    newBubble.empty = NO;
    if (arc4random() % 100 >= 90) {
        newBubble.empty = YES;
    }
    if ([newBubble.bubbleColor isEqualToString:@"allColor"]) {
        newBubble.empty = NO;
    }
    if (!self.advancedMode) {
        newBubble.empty = NO;
    }
    return newBubble;
}

- (void)addBubble: (BubblePiece *)newBubble {
    if (self.bubbleNumber < 100) {
        position newPosition = [self pickEmptyPosition];
        [[self.gameBoard objectAtIndex:newPosition.row] replaceObjectAtIndex:newPosition.column withObject:newBubble];
        newBubble.currentPosition = newPosition;
        [self blowBubbles:newBubble fromPosition:newPosition];
        self.bubbleNumber++;
    }
}

- (id)choseCellAtPosition: (position)position {
    NSInteger row = position.row;
    NSInteger column = position.column;
    return [[self.gameBoard objectAtIndex:row] objectAtIndex:column];
}

- (BOOL)isGameBoardFull {
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
            if(![self.gameBoard[i][j] isKindOfClass:[BubblePiece class]]) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSString *)pickRandomBubble {
    NSUInteger prob = arc4random() % 100;
    if (prob >= 90 && self.advancedMode == YES) {
        return @"allColor";
    }
    return [self.validBubbleColor objectAtIndex:(arc4random() % [self.validBubbleColor count])];
}

- (position)pickEmptyPosition {
    NSMutableArray *validPosition = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
            id cell = [[self.gameBoard objectAtIndex:i] objectAtIndex:j];
            if (![cell isKindOfClass:[BubblePiece class]]) {
                NSNumber *row = [NSNumber numberWithInt:i];
                NSNumber *column = [NSNumber numberWithInt:j];
                NSArray *array = @[row, column];
                [validPosition addObject:array];
            }
        }
    }
    NSInteger index= arc4random() % [validPosition count];
    position position;
    position.row = [[[validPosition objectAtIndex:index] firstObject] integerValue];
    position.column = [[[validPosition objectAtIndex:index] lastObject] integerValue];
    return position;
}

- (BOOL)isLocation: (position)position1
           equalTo: (position)position2 {
    return (position1.row == position2.row && position1.column == position2.column) ? YES : NO;
}

BOOL **mark;
NSArray *path;

- (BOOL)validPathCell: (id)cell {
    if ([cell isKindOfClass:[NSString class]]) {
        return true;
    }
    else {
        BubblePiece *bubble = (BubblePiece *)cell;
        if (bubble.empty) {
            return true;
        }
    }
    return false;
}

- (NSMutableArray *)findPath: (NSMutableArray *)stack
                  toPosition: (position)desPosition
           movingEmptyBubble: (BOOL)empty {
    
    if (![stack count]) {
        return nil;
    }
    NSArray *currentPosition = [stack firstObject];
    NSInteger currentRow = [[currentPosition firstObject] integerValue];
    NSInteger currentColumn = [[currentPosition objectAtIndex:1] integerValue];
    mark[currentRow][currentColumn] = YES;
    
    NSMutableArray *soretedPositionByDistance = [[NSMutableArray alloc] init];
    
    if (currentRow == desPosition.row && currentColumn == desPosition.column) {
        path = [stack copy];
        return stack;
    }
    
    if (currentRow) {
        id aboveCell = [[self.gameBoard objectAtIndex:currentRow - 1] objectAtIndex:currentColumn];
        if (([self validPathCell:aboveCell] || empty) && !mark[currentRow - 1][currentColumn]) {
            NSNumber *row = [NSNumber numberWithInteger:currentRow - 1];
            NSNumber *column = [NSNumber numberWithInteger:currentColumn];
            NSArray *pos = @[row, column];
            [soretedPositionByDistance addObject:pos];
        }
    }
    
    if (currentColumn) {
        id aboveCell = [[self.gameBoard objectAtIndex:currentRow] objectAtIndex:currentColumn - 1];
        if (([self validPathCell:aboveCell] || empty) && !mark[currentRow][currentColumn - 1] ) {
            NSNumber *row = [NSNumber numberWithInteger:currentRow];
            NSNumber *column = [NSNumber numberWithInteger:currentColumn - 1];
            NSArray *pos = @[row, column];
            [soretedPositionByDistance addObject:pos];
        }
    }
    
    if (currentRow < 9) {
        id aboveCell = [[self.gameBoard objectAtIndex:currentRow + 1] objectAtIndex:currentColumn];
        if (([self validPathCell:aboveCell] || empty) && !mark[currentRow + 1][currentColumn]) {
            NSNumber *row = [NSNumber numberWithInteger:currentRow + 1];
            NSNumber *column = [NSNumber numberWithInteger:currentColumn];
            NSArray *pos = @[row, column];
            [soretedPositionByDistance addObject:pos];
        }
    }
    
    if (currentColumn < 9) {
        id aboveCell = [[self.gameBoard objectAtIndex:currentRow] objectAtIndex:currentColumn + 1];
        if (([self validPathCell:aboveCell] || empty) && !mark[currentRow][currentColumn + 1]) {
            NSNumber *row = [NSNumber numberWithInteger:currentRow];
            NSNumber *column = [NSNumber numberWithInteger:currentColumn + 1];
            NSArray *pos = @[row, column];
            [soretedPositionByDistance addObject:pos];
        }
    }
    
    if ([soretedPositionByDistance count]) {
        [soretedPositionByDistance sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSInteger row1 = [[obj1 firstObject] integerValue];
            NSInteger column1 = [[obj1 lastObject] integerValue];
            NSInteger row2 = [[obj2 firstObject] integerValue];
            NSInteger column2 = [[obj2 lastObject] integerValue];
            NSInteger dis1= (row1 - desPosition.row) * (row1 - desPosition.row)+ (column1 - desPosition.column) * (column1 - desPosition.column);
            NSInteger dis2= (row2 - desPosition.row) * (row2 - desPosition.row)+ (column2 - desPosition.column) * (column2 - desPosition.column);
            if (dis1 < dis2) {
                return NSOrderedAscending;
            }
            if (dis1 > dis2) {
                return  NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        for (NSArray *array in soretedPositionByDistance) {
            [stack insertObject:array atIndex:0];
            [self findPath:stack toPosition:desPosition movingEmptyBubble:empty];
        }
    }
    [stack removeObjectAtIndex:0];
    return stack;
}



- (NSArray *)moveBubbleFrom:(position)originPosition to:(position)destinationPosition {
    BubblePiece *bubble = [[self.gameBoard objectAtIndex:originPosition.row] objectAtIndex:originPosition.column];
    path = nil;
    NSNumber *row = [NSNumber numberWithInteger:originPosition.row];
    NSNumber *column = [NSNumber numberWithInteger:originPosition.column];
    NSArray *pos = @[row, column];
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    [stack addObject:pos];
    
    mark = malloc(sizeof(BOOL *) * 10);
    for (int i = 0; i < 10; i++) {
        mark[i] = malloc(sizeof(BOOL) * 10);
    }
    for (int i = 0; i < 10; i ++) {
        for (int j = 0; j < 10; j ++) {
            mark[i][j] = NO;
        }
    }
    if (bubble.empty) {
        [self findPath:stack toPosition:destinationPosition movingEmptyBubble:YES];
    }
    else {
         [self findPath:stack toPosition:destinationPosition movingEmptyBubble:NO];
    }
    
    if (path) {
        NSString *string = [NSString stringWithFormat:@""];
        [[self.gameBoard objectAtIndex:destinationPosition.row] replaceObjectAtIndex:destinationPosition.column withObject:bubble];
        [[self.gameBoard objectAtIndex:originPosition.row] replaceObjectAtIndex:originPosition.column withObject:string];
        bubble.currentPosition = destinationPosition;
        [self blowBubbles:bubble fromPosition:destinationPosition];
    }
    for (int i = 0; i < 10; i++) {
        free(mark[i]);
    }
    free(mark);
    mark = NULL;
    return path;
}

- (void)blowBubbles: (BubblePiece *)bubble
       fromPosition: (position)destinationPosition {
    if ([bubble.bubbleColor isEqualToString:@"allColor"]) {
        NSUInteger number = 0;
        NSMutableArray *blow = [[NSMutableArray alloc] init];
        for (NSString *color in [BubblePiece validColor]) {
            bubble.bubbleColor = [NSString stringWithString:color];
            NSArray *blowForSingleColor = [self updateBoardFrom:destinationPosition];
            if ([blowForSingleColor count]) {
                [blow addObjectsFromArray:blowForSingleColor];
                number++;
            }
        }
        bubble.bubbleColor = @"allColor";
        if ([blow count]) {
            NSInteger bubbleNumber = [blow count];
            if (number == [[BubblePiece validColor] count]) {
                bubbleNumber = bubbleNumber / [[BubblePiece validColor] count];
                number = 1;
            }
            self.score += (bubbleNumber - 3 - number) * 5;
            self.bubbleNumber -= bubbleNumber;
            [self deleteBlowedBubbles:blow];
        }
    }
    else {
        NSArray *blow = [self updateBoardFrom:destinationPosition];
        if ([blow count]) {
            self.score += ([blow count] - 4) * 5;
            self.bubbleNumber -= [blow count];
            [self deleteBlowedBubbles:blow];
        }
    }
}


- (void)deleteBlowedBubbles: (NSArray *)blowList {
    for (NSArray *array in blowList) {
        NSInteger row = [[array firstObject] integerValue];
        NSInteger column = [[array lastObject] integerValue];
        [[self.gameBoard objectAtIndex:row] replaceObjectAtIndex:column withObject:[NSString stringWithFormat:@""]];
    }
}

- (NSArray *)updateBoardFrom: (position)position {
    BubblePiece *bubble = [[self.gameBoard objectAtIndex:position.row] objectAtIndex:position.column];
    NSMutableArray *blowUp = [[NSMutableArray alloc] init];
    
    //**********************************ROW********************************************//
    NSInteger left = position.column;
    NSInteger right = position.column;
    while (left > 0) {
        id temp = [[self.gameBoard objectAtIndex:position.row] objectAtIndex:left - 1];
        if ([temp isKindOfClass:[BubblePiece class]]) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                left--;
                continue;
            }
        }
        break;
    }
    while (right < 9) {
        id temp = [[self.gameBoard objectAtIndex:position.row] objectAtIndex:right + 1];
        if ([temp isKindOfClass:[BubblePiece class]]) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                right++;
                continue;
            }
        }
        break;
    }
    if (right - left + 1 >= 5) {
        for (NSInteger i = left; i <= right; i++) {
            if (i == position.column) {
                continue;
            }
            NSNumber *row = [NSNumber numberWithInteger:position.row];
            NSNumber *column = [NSNumber numberWithInteger:i];
            NSArray *array = @[row, column];
            [blowUp addObject:array];
        }
    }
    
    //**********************************COLUMN********************************************//
    left = position.row;
    right = position.row;
    while (left > 0) {
        id temp = [[self.gameBoard objectAtIndex:left - 1] objectAtIndex: position.column];
        if ([temp isKindOfClass:[BubblePiece class]]) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                left--;
                continue;
            }
        }
        break;
    }
    while (right < 9) {
        id temp = [[self.gameBoard objectAtIndex:right + 1] objectAtIndex:position.column];
        if ([temp isKindOfClass:[BubblePiece class]]) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                right++;
                continue;
            }
        }
        break;
    }
    if (right - left + 1 >= 5) {
        for (NSInteger i = left; i <= right; i++) {
            if (i == position.row) {
                continue;
            }
            NSNumber *row = [NSNumber numberWithInteger:i];
            NSNumber *column = [NSNumber numberWithInteger:position.column];
            NSArray *array = @[row, column];
            [blowUp addObject:array];
        }
    }
    
    //**********************************diaognal********************************************//
    NSInteger leftUpRow = position.row;
    NSInteger leftUpColumn = position.column;
    NSInteger rightDownRow = position.row;
    NSInteger rightDownColumn = position.column;
    while (leftUpRow > 0 && leftUpColumn > 0) {
        id temp = [[self.gameBoard objectAtIndex:leftUpRow - 1] objectAtIndex: leftUpColumn - 1];
        if ([temp isKindOfClass:[BubblePiece class]]) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                leftUpRow--;
                leftUpColumn--;
                continue;
            }
        }
        break;
    }
    while (rightDownRow < 9 && rightDownColumn < 9) {
        id temp = [[self.gameBoard objectAtIndex:rightDownRow + 1] objectAtIndex: rightDownColumn + 1];
        if ([temp isKindOfClass:[BubblePiece class]]) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                rightDownRow ++;
                rightDownColumn ++;
                continue;
            }
        }
        break;
    }
    if (rightDownRow - leftUpRow + 1 >= 5) {
        NSInteger i, j;
        for (i = leftUpRow, j=leftUpColumn; i <= rightDownRow; i++, j++) {
            if (i == position.row) {
                continue;
            }
            NSNumber *row = [NSNumber numberWithInteger:i];
            NSNumber *column = [NSNumber numberWithInteger:j];
            NSArray *array = @[row, column];
            [blowUp addObject:array];
        }
    }
    
    //**********************************diaognal********************************************//
    NSInteger leftDownRow = position.row;
    NSInteger leftDownColumn = position.column;
    NSInteger rightUpRow = position.row;
    NSInteger rightUpcolumn = position.column;
    
    while (leftDownRow < 9 && leftDownColumn > 0) {
        id temp = [[self.gameBoard objectAtIndex:leftDownRow + 1] objectAtIndex: leftDownColumn - 1];
        if ([temp isKindOfClass:[BubblePiece class]] ) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                leftDownRow++;
                leftDownColumn--;
                continue;
            }
        }
        break;
    }
    while (rightUpRow > 0 && rightUpcolumn < 9) {
        id temp = [[self.gameBoard objectAtIndex:rightUpRow - 1] objectAtIndex: rightUpcolumn + 1];
        if ([temp isKindOfClass:[BubblePiece class]]) {
            BubblePiece *tempBubble = (BubblePiece *)temp;
            if ([tempBubble.bubbleColor isEqualToString:bubble.bubbleColor] || [tempBubble.bubbleColor isEqualToString:@"allColor"]) {
                rightUpRow--;
                rightUpcolumn++;
                continue;
            }
        }
        break;
    }
    if (leftDownRow - rightUpRow + 1 >= 5) {
        NSInteger i, j;
        for (i = leftDownRow, j=leftDownColumn; i >= rightUpRow; i--, j++) {
            if (i == position.row) {
                continue;
            }
            NSNumber *row = [NSNumber numberWithInteger:i];
            NSNumber *column = [NSNumber numberWithInteger:j];
            NSArray *array = @[row, column];
            [blowUp addObject:array];
        }
    }
    if ([blowUp count]) {
        NSNumber *row = [NSNumber numberWithInteger: position.row];
        NSNumber *column = [NSNumber numberWithInteger: position.column];
        NSArray *array = @[row, column];
        [blowUp addObject:array];
    }
    return blowUp;
}

- (void)setTopScore: (NSInteger)score
       advancedMode: (BOOL)advancedMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!advancedMode) {
        NSMutableArray *topScores;
        if (![defaults objectForKey:@"topScore"]) {
            topScores = [[NSMutableArray alloc] init];
            [topScores addObject:[NSString stringWithFormat:@"%ld", (long)score]];
        }
        else {
            NSArray *scores = [defaults objectForKey:@"topScore"];
            topScores = scores.mutableCopy;
            [topScores addObject:[NSString stringWithFormat:@"%ld", (long)score]];
            [topScores sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSInteger score1 = [obj1 integerValue];
                NSInteger score2 = [obj2 integerValue];
                if (score1 < score2) {
                    return NSOrderedAscending;
                }
                if (score1 > score2) {
                    return NSOrderedDescending;
                }
                return NSOrderedSame;
            }];
            if ([topScores count] > 10) {
                [topScores removeObjectAtIndex:0];
            }
        }
        [defaults setObject:topScores forKey:@"topScore"];
    }
    else {
        NSMutableArray *topScores;
        if (![defaults objectForKey:@"topScoreAdvanced"]) {
            topScores = [[NSMutableArray alloc] init];
            [topScores addObject:[NSString stringWithFormat:@"%ld", (long)score]];
        }
        else {
            NSArray *scores = [defaults objectForKey:@"topScoreAdvanced"];
            topScores = scores.mutableCopy;
            [topScores addObject:[NSString stringWithFormat:@"%ld", (long)score]];
            [topScores sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSInteger score1 = [obj1 integerValue];
                NSInteger score2 = [obj2 integerValue];
                if (score1 < score2) {
                    return NSOrderedAscending;
                }
                if (score1 > score2) {
                    return NSOrderedDescending;
                }
                else {
                    return NSOrderedSame;
                }
            }];
            if ([topScores count] > 10) {
                [topScores removeObjectAtIndex:0];
            }
        }
        [defaults setObject:topScores forKey:@"topScoreAdvanced"];
    }
}

- (NSUInteger)getTopScoreWithAdvancedMode: (BOOL)advancedMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!advancedMode) {
        if (![defaults objectForKey:@"topScore"]) {
            return 0;
        }
        else {
            NSArray *topScores = [defaults objectForKey:@"topScore"];
            NSUInteger score = [[topScores lastObject] integerValue];
            return score;
        }
    }
    else {
        if (![defaults objectForKey:@"topScoreAdvanced"]) {
            return 0;
        }
        else {
            NSArray *topScores = [defaults objectForKey:@"topScoreAdvanced"];
            NSUInteger score = [[topScores lastObject] integerValue];
            return score;
        }
    }
}


@end
