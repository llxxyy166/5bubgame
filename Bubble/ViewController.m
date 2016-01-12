//
//  ViewController.m
//  Bubble
//
//  Created by xinye lei on 15/12/31.
//  Copyright © 2015年 xinye lei. All rights reserved.
//

#import "ViewController.h"
#import "BubbleGame.h"
#import "BubbleView.h"
#import "ScoreBarView.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *gameBoardView;
@property (strong, nonatomic) BubbleGame *game;
@property (strong, nonatomic) NSMutableArray *BubbleViews;
@property (strong, nonatomic) BubblePiece *chosenBubblePiece;
@property (weak, nonatomic) IBOutlet ScoreBarView *scoreBar;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutletCollection(BubbleView) NSArray *nextTurnBubblesViews;

@property (weak, nonatomic) IBOutlet UILabel *mode;
@property (weak, nonatomic) IBOutlet UISwitch *modeSwitch;
@property (weak, nonatomic) UITextView *helpView;
@end

@implementation ViewController

- (IBAction)helpButton:(UIButton *)sender {
    //NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.gameBoardView.bounds.size];
    if (!self.helpView) {
        CGRect frame = self.gameBoardView.frame;
//        frame.origin.x += frame.size.width / 4;
//        frame.size.width /= 2;
//        frame.size.height /= 2;
        UITextView *helpView = [[UITextView alloc] initWithFrame:frame];
        helpView.textColor = [UIColor redColor];
        helpView.textAlignment = NSTextAlignmentLeft;
        helpView.backgroundColor = self.gameBoardView.backgroundColor;
        helpView.font = [UIFont fontWithName:@"Arial" size:20];
        helpView.text = @"Move Bubbles Around! More than 5 connected bubles with same color in a row, column or diagonal will lead them blow up!\n\nIn advanced mode, there are hollow bubbles which will not block or blocked the way by other bubbles and colorful bubbles which can be counted as any color.";
        //helpView.alpha = 0.5;
        [self.view addSubview:helpView];
        self.helpView = helpView;
        for (id view in self.BubbleViews) {
            if ([view isKindOfClass:[BubbleView class]]) {
                BubbleView *bubbleView = (BubbleView *)view;
                bubbleView.alpha = 0;
            }
        }
        [sender setTitle:@"Hide Help" forState:UIControlStateNormal];
    }
    else {
        [self.helpView removeFromSuperview];
        self.helpView = nil;
        [sender setTitle:@"Help" forState:UIControlStateNormal];
        for (id view in self.BubbleViews) {
            if ([view isKindOfClass:[BubbleView class]]) {
                BubbleView *bubbleView = (BubbleView *)view;
                bubbleView.alpha = 1;
            }
        }
    }
}


NSMutableArray *blowupQueue, *appearQueue;
- (IBAction)resetButton {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restart?" message:@"Are you sure you want to start a new game?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self resetAction];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController: alert animated:YES completion:nil];
}

- (void)gameOver {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Over" message:[NSString stringWithFormat:@"Your Score: %ld", (long)self.game.score] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self resetAction];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetAction {
    if (self.game.score) {
        [self.game setTopScore:self.game.score advancedMode:self.game.advancedMode];
    }
    for (id view in self.BubbleViews) {
        if ([view isKindOfClass:[BubbleView class]]) {
            [view removeFromSuperview];
        }
    }
    self.BubbleViews = nil;
    self.game = nil;
    [self setUpGame];
}

- (NSMutableArray *)BubbleViews {
    if (!_BubbleViews) {
        _BubbleViews = [[NSMutableArray alloc] initWithCapacity:100];
        for (int i = 0; i < 100; i++) {
            [_BubbleViews addObject:[NSString stringWithFormat:@""]];
        }
    }
    return _BubbleViews;
}

- (BubbleGame *)game {
    if (!_game) {
        _game = [[BubbleGame alloc] initWithOption:self.modeSwitch.isOn];
    }
    return _game;
}

- (IBAction)modeSwitch:(UISwitch *)sender {
    [self resetAction];
}


- (void)addBubble: (BubblePiece *)bubble
      transparent: (BOOL)transparent {
    position position = bubble.currentPosition;
    CGRect frame = [self frameWithPosition:position];
    BubbleView *bubbleView = [[BubbleView alloc] initWithFrame:frame];
    bubbleView.chosen = NO;
    bubbleView.backgroundColor = [UIColor clearColor];
    if (transparent) {
        bubbleView.alpha = 0;
    }
    else {
        bubbleView.alpha = 1;
    }
    bubbleView.bubbleColor = bubble.bubbleColor;
    bubbleView.empty = bubble.empty;
    [self.gameBoardView addSubview:bubbleView];
    [self.BubbleViews replaceObjectAtIndex:[self indexWithPosition:position] withObject:bubbleView];
    [appearQueue addObject:bubbleView];
}

- (void)updateScoreWithColor: (NSString *)color {
    NSUInteger currentScore = self.game.score;
    NSUInteger topScore= [self.game getTopScoreWithAdvancedMode:self.game.advancedMode];
    if (self.game.score > topScore) {
        topScore = currentScore;
    }
    self.scoreLabel.adjustsFontSizeToFitWidth = YES;
    self.scoreLabel.text = [NSString stringWithFormat:@"Current Score: %lu   /   Top Score: %lu", (unsigned long)currentScore, (unsigned long)topScore];
    self.scoreBar.score = currentScore;
    self.scoreBar.topScore = topScore;
    self.scoreBar.displayColor = color;
}

- (void)updateNextTurnBubblesViews {
    for (int i = 0; i < 3; i++) {
        BubblePiece *piece = [self.game.nextTurnBubbles objectAtIndex:i];
        BubbleView *view = [self.nextTurnBubblesViews objectAtIndex:i];
        view.bubbleColor = piece.bubbleColor;
        view.empty = piece.empty;
        if (![view.subviews isKindOfClass:[self.gameBoardView class]]) {
            [self.gameBoardView addSubview:view];
        }
    }
}

- (void)setUpGame {
    self.chosenBubblePiece = nil;
    self.modeSwitch.enabled = YES;
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
            id cell = [[self.game.gameBoard objectAtIndex:i] objectAtIndex:j];
            if ([cell isKindOfClass:[BubblePiece class]]) {
                BubblePiece *bubble = (BubblePiece *)cell;
                [self addBubble:bubble transparent:YES];
            }
        }
    }
    [UIView animateWithDuration:2 animations:^{
        [self animateViewAppearCode];
    }];
    [self updateNextTurnBubblesViews];
    [self updateScoreWithColor:nil];
    [blowupQueue removeAllObjects];
    [appearQueue removeAllObjects];
}
- (void)viewDidAppear:(BOOL)animated {
    if (![self.mode.text length]) {
        [super viewDidAppear:YES];
        self.mode.text = [NSString stringWithFormat:@"Advanced\nMode"];
        self.mode.adjustsFontSizeToFitWidth = YES;
        blowupQueue = [[NSMutableArray alloc] init];
        appearQueue = [[NSMutableArray alloc] init];
        [self setUpGame];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self.gameBoardView addGestureRecognizer:tapGesture];
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//        panGesture.minimumNumberOfTouches = 1;
//        panGesture.maximumNumberOfTouches = 1;
//        [self.gameBoardView.superview addGestureRecognizer:panGesture];
    }
}

//- (void)pan: (UIPanGestureRecognizer *)sender {
//    CGRect frame = self.bombLabel.frame;
//    CGPoint location = [sender locationInView:sender.view];
//    if (location.x > frame.origin.x && location.x < frame.origin.x + frame.size.width) {
//        if (location.y > frame.origin.y && location.y < frame.origin.y + frame.size.height) {
////            if (sender.state == UIGestureRecognizerStateBegan) {
////                self.bombLabel.center = location;
////                NSLog(@"as");
////            }
//            self.bombLabel.center = location;
//        }
//    }
//}

- (void)tap: (UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.modeSwitch.enabled = NO;
        [self updateNextTurnBubblesViews];
        CGPoint location = [sender locationInView:self.gameBoardView];
        position position = [self getPositionByPoint:location];
        id cell = [self.game choseCellAtPosition:position];
        if (!self.chosenBubblePiece) {
            if ([cell isKindOfClass:[BubblePiece class]]) {
                NSUInteger index= [self indexWithPosition:position];
                BubbleView *view = [self.BubbleViews objectAtIndex:index];
                view.chosen = YES;
                self.chosenBubblePiece = cell;
            }
        }
        else {
            NSUInteger index = [self indexWithPosition:self.chosenBubblePiece.currentPosition];
            BubbleView *view = [self.BubbleViews objectAtIndex:index];
            view.chosen = NO;
            if (![cell isKindOfClass:[BubblePiece class]]) {
                [self moveBubbleFrom:self.chosenBubblePiece.currentPosition to:position];
            }
            self.chosenBubblePiece = nil;
        }
    }
}

#define TIME_COST_PER_GRID 0.05
- (void)animateMovementWithPath: (NSArray *)path
                        forView: (BubbleView *)view {
    double timeStamp = 0;
    for (NSInteger i = [path count] - 1; i >= 0; i--) {
        NSNumber *nsRow = [[path objectAtIndex:i] firstObject];
        NSNumber *nsColumn = [[path objectAtIndex:i] lastObject];
        NSInteger row = [nsRow integerValue];
        NSInteger column = [nsColumn integerValue];
        position pos;
        pos.row = row;
        pos.column = column;
        CGPoint center = [self centerWithPosition:pos];
        [UIView animateWithDuration:TIME_COST_PER_GRID delay:timeStamp options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            view.center = center;
        } completion:NULL];
        timeStamp += (double)TIME_COST_PER_GRID;
    }
    [self updateGameBoard];
    if ([blowupQueue count]) {
        BubbleView *view = blowupQueue[0];
        NSString *color = view.bubbleColor;
        [self updateScoreWithColor:color];
        [UIView animateWithDuration:0.1 delay:timeStamp options:UIViewAnimationOptionAutoreverse animations:^{
            [UIView setAnimationRepeatCount:3];
            [self animateBlowupCode];
        } completion:^(BOOL finished) {
            if (finished) {
                [self removeBlowedBubble];
            }
        }];
        timeStamp += 1;
    }
    if (![blowupQueue count] || !self.game.bubbleNumber) {
        for (BubblePiece *bubble in self.game.nextTurnBubbles) {
            if (self.game.bubbleNumber == 100) {
                break;
            }
            [self.game addBubble: bubble];
            [self addBubble:bubble transparent:YES];
        }
        self.game.nextTurnBubbles = nil;
        [self updateNextTurnBubblesViews];
        [self updateGameBoard];
    }
    if ([appearQueue count]) {
        [UIView animateWithDuration:1 delay:timeStamp options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self animateViewAppearCode];
        } completion:^(BOOL finished) {
            if (finished) {
                if (self.game.bubbleNumber == 100) {
                    [self gameOver];
                }
            }
        }];
        timeStamp += 1;
        if ([blowupQueue count]) {
            BubbleView *view = blowupQueue[0];
            NSString *color = view.bubbleColor;
            [self updateScoreWithColor:color];
            [UIView animateWithDuration:0.1 delay:timeStamp options:UIViewAnimationOptionAutoreverse animations:^{
                [UIView setAnimationRepeatCount:3];
                [self animateBlowupCode];
            } completion:^(BOOL finished) {
                [self removeBlowedBubble];
            }];
            timeStamp += 1;
        }
    }
}

- (void)animateBlowupCode {
    for (BubbleView *view in blowupQueue) {
        view.alpha = 0;
    }
}

- (void)removeBlowedBubble {
    for (BubbleView *view in blowupQueue) {
        [view removeFromSuperview];
    }
    [blowupQueue removeAllObjects];
}


- (void)animateViewAppearCode {
    for (BubbleView *view in appearQueue) {
        view.alpha = 1;
    }
    [appearQueue removeAllObjects];
}


- (void)updateGameBoard {
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
            position position;
            position.row = i;
            position.column = j;
            NSUInteger index= [self indexWithPosition:position];
            id cellInView = [self.BubbleViews objectAtIndex:index];
            id cellInModel = [[self.game.gameBoard objectAtIndex:i] objectAtIndex:j];
            if ([cellInView isKindOfClass:[BubbleView class]] && [cellInModel isKindOfClass:[NSString class]]) {
                [self.BubbleViews replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@""]];
                [blowupQueue addObject:cellInView];
            }
            if ([cellInView isKindOfClass:[NSString class]] && [cellInModel isKindOfClass:[BubblePiece class]]) {
                BubblePiece *bubble = (BubblePiece *)cellInModel;
                [self addBubble:bubble transparent: YES];
            }
        }
    }
}

- (void)moveBubbleFrom: (position)originPosition
                    to:(position)destinationPosition {
    NSInteger destinationIndex = [self indexWithPosition:destinationPosition];
    NSInteger originIndex = [self indexWithPosition:originPosition];
    id cell = [self.BubbleViews objectAtIndex:destinationIndex];
    if (![cell isKindOfClass:[BubbleView class]]) {
        NSArray *path = [self.game moveBubbleFrom:originPosition to:destinationPosition];
        BubbleView *view = [self.BubbleViews objectAtIndex:originIndex];
        if (path) {
            [self.BubbleViews replaceObjectAtIndex:originIndex withObject:[NSString stringWithFormat:@""]];
            [self.BubbleViews replaceObjectAtIndex:destinationIndex withObject:view];
            [self animateMovementWithPath:path forView:view];
        }
        else {
            CGPoint orginCenter = view.center;
            CGFloat bounceDis = view.bounds.size.height / 10;
            CGPoint newCenter = orginCenter;
            newCenter.y -= bounceDis;
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
                [UIView setAnimationRepeatCount:3];
                view.center = newCenter;
            } completion:^(BOOL finished) {
                if (finished) {
                    view.center = orginCenter;
                }
            }];
        }
    }
}


#pragma mark positionConversion

- (position)getPositionByPoint: (CGPoint)location {
    CGFloat widthPerGrid = self.gameBoardView.bounds.size.width / 10;
    CGFloat heightPerGrid = self.gameBoardView.bounds.size.height / 10;
    NSInteger row = (location.y - self.gameBoardView.bounds.origin.y) / heightPerGrid;
    NSInteger column = (location.x - self.gameBoardView.bounds.origin.x) / widthPerGrid;
    position position;
    position.row = row;
    position.column = column;
    return position;
}

- (CGRect)frameWithPosition: (position)position {
    NSInteger row = position.row;
    NSInteger column = position.column;
    CGFloat widthPerGrid = self.gameBoardView.bounds.size.width / 10;
    CGFloat heightPerGrid = self.gameBoardView.bounds.size.height / 10;
    CGRect frame;
    frame.origin.x = self.gameBoardView.bounds.origin.x + column * widthPerGrid;
    frame.origin.y = self.gameBoardView.bounds.origin.y + row * heightPerGrid;
    frame.size.width = widthPerGrid;
    frame.size.height = heightPerGrid;
    return frame;
}

- (CGPoint)centerWithPosition: (position)position {
    NSInteger row = position.row;
    NSInteger column = position.column;
    CGFloat widthPerGrid = self.gameBoardView.bounds.size.width / 10;
    CGFloat heightPerGrid = self.gameBoardView.bounds.size.height / 10;
    CGPoint center;
    center.x = self.gameBoardView.bounds.origin.x + column * widthPerGrid + 0.5 * widthPerGrid;
    center.y = self.gameBoardView.bounds.origin.y + row * heightPerGrid + 0.5 * heightPerGrid;
    return center;
}

- (NSUInteger)indexWithPosition: (position)position {
    return position.row * 10 + position.column;
}

- (position)positionWithIndex: (NSUInteger)index {
    NSInteger row = index / 10;
    NSInteger column = index - 10 * row;
    position position;
    position.row = row;
    position.column = column;
    return position;
}

@end
