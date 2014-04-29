//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Tile.h"

@interface MainScene() {
    CCLabelTTF *_lbNextTile;
    CCLabelTTF *_lbScore;
    CCNodeColor *_retryButton;
    int nextTile;
    int score;
    __block int addedScore;
    CCLabelTTF *_lbTime;
    CCNodeColor *_bestBar;
    CCNodeColor *_gameOverBar;
    CCTime totalTime;
    CCNode *_board;
    int numberBoard[4][4];
    Tile *tileBoard[4][4];
    __block int inQueue;
    __block BOOL isMoving;
    BOOL isGameStart;
    BOOL isGameOver;
    
    int bestScore;
    CGFloat bestTime;
    BOOL moveableRow[4];
    BOOL moveableCol[4];
}

@end

@implementation MainScene

#pragma mark - init

//initialization
- (void)didLoadFromCCB
{
    //add swipe recoginzer
    UISwipeGestureRecognizer *swipeLeft, *swipeRight, *swipeUp, *swipeDown;
    swipeLeft   = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeft)];
    swipeRight  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight)];
    swipeUp     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveUp)];
    swipeDown   = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveDown)];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [longPress setMinimumPressDuration:0.5];
    [longPress setAllowableMovement:50];
    
    swipeLeft.direction     = UISwipeGestureRecognizerDirectionLeft;
    swipeRight.direction    = UISwipeGestureRecognizerDirectionRight;
    swipeUp.direction       = UISwipeGestureRecognizerDirectionUp;
    swipeDown.direction     = UISwipeGestureRecognizerDirectionDown;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:longPress];
    
    //default value
    memset(numberBoard, -1, sizeof(numberBoard));
    inQueue = 0;
    isMoving = NO;
    isGameStart = NO;
    
    //initial state
    [self spawnInitializeTile];
    [_bestBar setVisible:NO];
    [_gameOverBar setVisible:NO];
    [_retryButton setVisible:NO];
    score = 0;
    nextTile = 2;
    
    bestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"My2048BestScore"];
    bestTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"My2048BestTime"];
}

- (void)spawnInitializeTile
{
    //default state: 2 tiles '2' and 1 tile '1'
    memset(moveableCol, YES, sizeof(moveableCol));
    memset(moveableRow, YES, sizeof(moveableRow));
    [self addTileNumber:2 position:[self getRandomBlankTile]];
    [self addTileNumber:2 position:[self getRandomBlankTile]];
    [self addTileNumber:4 position:[self getRandomBlankTile]];
}

#pragma mark - utility

//generate random blank tile to spawn new tile
- (CGPoint)getRandomBlankTile
{
    int r, c;
    do {
        r = arc4random_uniform(4);
        c = arc4random_uniform(4);
    } while (numberBoard[r][c] != -1 || !moveableCol[c] || !moveableRow[r]);
    return ccp(r, c);
}

//add new tile to board
- (void)addTileNumber:(int)number position:(CGPoint)position
{
    //update board state
    Tile *tile = (Tile *)[CCBReader load:@"Tile"];
    [tile setNumber:number];
    tileBoard[(int)position.x][(int)position.y] = tile;
    numberBoard[(int)position.x][(int)position.y] = number;
    
    //position (normalized)
    tile.positionType = CCPositionTypeNormalized;
    tile.position = ccp(0.125 + 0.25 * position.y, 0.125 + 0.25 * position.x);
    
    [_board addChild:tile];
    
    //effect
    tile.scale = 0.1;
    CCAction *appear = [CCActionScaleTo actionWithDuration:0.2 scale:1];
    [tile runAction:appear];
    
}

- (void)spawnNewTile
{
    [self addTileNumber:nextTile position:[self getRandomBlankTile]];
    
    //generate next tile number
    int seed = arc4random_uniform(1 << 20);
    
    if (score < 5000) {
        if (seed < (1 << 20) - (1 << 16))
            nextTile = 2;
        else
            nextTile = 4;
    } else if (score < 10000) {
        if (seed < (1 << 20) - (1 << 16))
            nextTile = 2;
        else if (seed < (1 << 20) - (1 << 12)) {
            nextTile = 4;
        } else {
            nextTile = 8;
        }
    } else {
        if (seed < (1 << 19) + (1 << 18)) {
            nextTile = 2;
        } else if (seed < (1 << 19) + (1 << 18) + (1 << 17)) {
            nextTile = 4;
        } else if (seed < (1 << 19) + (1 << 18) + (1 << 17) + (1 << 16)) {
            nextTile = 8;
        } else if (seed < (1 << 19) + (1 << 18) + (1 << 17) + (1 << 16) + (1 << 15)) {
            nextTile = 16;
        } else if (seed < (1 << 19) + (1 << 18) + (1 << 17) + (1 << 16) + (1 << 15) + (1 << 14)) {
            nextTile = 32;
        } else if (seed < (1 << 19) + (1 << 18) + (1 << 17) + (1 << 16) + (1 << 15) + (1 << 14) + (1 << 13)) {
            nextTile = 64;
        } else {
            nextTile = 128;
        }
    }
    
    if (nextTile == 2)
        [_lbNextTile setString:@"2"];
    else
        [_lbNextTile setString:@"+"];
}

- (void)addScore:(int)newScore
{
    if (newScore == 0)
        return;
    score += newScore;
    CCLabelTTF *lbAdded = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d", newScore] fontName:@"GillSans" fontSize:20];
    [lbAdded setAnchorPoint:ccp(0.5, 0.5)];
    [lbAdded setFontColor:[CCColor colorWithCcColor3b:ccc3(246, 94, 59)]];
    [lbAdded setPosition:ccp(0.5, 0.5)];
    [lbAdded setPositionType:CCPositionTypeNormalized];
    [_lbScore addChild:lbAdded];
    
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:1 position:ccp(0.5, 2)];
    CCActionFadeOut *fade = [CCActionFadeOut actionWithDuration:1];
    CCActionCallBlock *cleanup = [CCActionCallBlock actionWithBlock:^{
        [lbAdded removeFromParentAndCleanup:YES];
    }];
    
    [lbAdded runAction:[CCActionSequence actions:[CCActionSpawn actions:move, fade, nil], cleanup, nil]];
    
    [_lbScore setString:[NSString stringWithFormat:@"%d", score]];
}

#pragma mark - game logic

- (void)update:(CCTime)delta
{
    if (!isGameStart)
        return;
    if (isGameOver)
        return;
    totalTime += delta;
    [_lbTime setString:[NSString stringWithFormat:@"%0.2f", totalTime]];
}

- (void)moveTileFrom:(CGPoint)source To:(CGPoint)destination AndMerge:(BOOL)isMerge
{
    //update moveable state
    if (source.x == destination.x)
        moveableRow[(int)source.x] = YES;
    if (source.y == destination.y)
        moveableCol[(int)source.y] = YES;
    
    //increase queue size of moving action
    inQueue++;
    
    //backup instance for animation
    Tile *temp = tileBoard[(int)source.x][(int)source.y];
    
    //update score
    addedScore += (isMerge ? numberBoard[(int)source.x][(int)source.y] * 2: 0);
    
    //update board state
    numberBoard[(int)destination.x][(int)destination.y] = numberBoard[(int)source.x][(int)source.y] * (isMerge ? 2 : 1);
    numberBoard[(int)source.x][(int)source.y] = -1;
    if (!isMerge) {
        tileBoard[(int)destination.x][(int)destination.y] = tileBoard[(int)source.x][(int)source.y];
    }
    tileBoard[(int)source.x][(int)source.y] = nil;
    
    //animation
    CGFloat speed = 750;
    CGFloat duration = ccpDistance(ccp(0.125 + 0.25 * destination.y, 0.125 + 0.25 * destination.x), temp.position) * _board.boundingBox.size.width / speed;
    
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:duration position:ccp(0.125 + 0.25 * destination.y, 0.125 + 0.25 * destination.x)];
    //complete block
    CCActionCallBlock *remove = [CCActionCallBlock actionWithBlock:^{
        //decrease queue size of moving action
        inQueue--;
        
        if (isMerge) {
            //cleanup source tile
            [temp removeFromParentAndCleanup:YES];
            //update destination tile and run effect
            [tileBoard[(int)destination.x][(int)destination.y] setNumber:numberBoard[(int)destination.x][(int)destination.y]];
            [tileBoard[(int)destination.x][(int)destination.y] bouncing];
        }
        //all moving action is completed
        if (inQueue == 0) {
            isMoving = NO;
            [self spawnNewTile];
            //update score
            [self addScore:addedScore];
            
            if ([self isGameOver])
                [self handleGameOver];
        }
    }];
    
    [temp runAction:[CCActionSequence actions:move, remove, nil]];
    if (isMerge)
        [temp fadeOut:duration];
}

- (BOOL)isGameOver
{
    for (int r = 0; r < 4; r++)
        for (int c = 0; c < 4; c++)
            if (numberBoard[r][c] == -1)
                return NO;
    for (int r = 0; r < 4; r++)
        for (int c = 0; c < 3; c++)
            if (numberBoard[r][c] == numberBoard[r][c + 1])
                return NO;
    for (int c = 0; c < 4; c++)
        for (int r = 0; r < 3; r++)
            if (numberBoard[r][c] == numberBoard[r + 1][c])
                return NO;
    isGameOver = YES;
    return YES;
}

- (void)retry
{
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.5]];
}

- (void)handleGameOver
{
    if (score > bestScore || (score == bestScore && totalTime < bestTime)) {
        bestScore = score;
        bestTime = totalTime;
        [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:@"My2048BestScore"];
        [[NSUserDefaults standardUserDefaults] setFloat:bestTime forKey:@"My2048BestTime"];
    }
    [_gameOverBar setVisible:YES];
    [_retryButton setVisible:YES];
}

#pragma mark - Handle Swipes
- (void)moveLeft
{
    isGameStart = YES;
    //block swipe if previous swipe is running
    if (isMoving)
        return;
    
    //semaphore
    isMoving = YES;
    inQueue = 0;
    addedScore = 0;
    memset(moveableCol, NO, sizeof(moveableCol));
    moveableCol[3] = YES;
    memset(moveableRow, NO, sizeof(moveableRow));
    
    //iterate each row
    for (int r = 0; r < 4; r++) {
        //lock is the first available column to move to in current row
        int lock = 0;
        for (int c = 0; c < 4; c++)
            if (numberBoard[r][c] != -1) {
                int i = c - 1;
                while (i > lock - 1 && numberBoard[r][i] == -1)
                    i--;
                if (i == lock - 1) {
                    if (c != lock)
                        [self moveTileFrom:ccp(r, c) To:ccp(r, lock) AndMerge:NO];
                }
                else {
                    if (numberBoard[r][c] == numberBoard[r][i]) {
                        //merge and update lock
                        [self moveTileFrom:ccp(r, c) To:ccp(r, i) AndMerge:YES];
                        lock = i + 1;
                    } else if (i != c - 1) {
                        [self moveTileFrom:ccp(r, c) To:ccp(r, i + 1) AndMerge:NO];
                    }
                }
            }
    }
    //guaratee swipe action is complete (in case no tile moved)
    if (inQueue == 0)
        isMoving = NO;
}

//similar with moveLeft

- (void)moveRight
{
    isGameStart = YES;
    if (isMoving)
        return;
    isMoving = YES;
    inQueue = 0;
    addedScore = 0;
    
    memset(moveableCol, NO, sizeof(moveableCol));
    moveableCol[0] = YES;
    memset(moveableRow, NO, sizeof(moveableRow));
    
    for (int r = 0; r < 4; r++) {
        int lock = 3;
        for (int c = 3; c >= 0; c--)
            if (numberBoard[r][c] != -1) {
                int i = c + 1;
                while (i < lock + 1 && numberBoard[r][i] == -1)
                    i++;
                if (i == lock + 1) {
                    if (c != lock)
                        [self moveTileFrom:ccp(r, c) To:ccp(r, lock) AndMerge:NO];
                }
                else {
                    if (numberBoard[r][c] == numberBoard[r][i]) {
                        [self moveTileFrom:ccp(r, c) To:ccp(r, i) AndMerge:YES];
                        lock = i - 1;
                    } else if (i != c + 1) {
                        [self moveTileFrom:ccp(r, c) To:ccp(r, i - 1) AndMerge:NO];
                    }
                }
            }
    }
    if (inQueue == 0)
        isMoving = NO;
}

- (void)moveUp
{
    isGameStart = YES;
    if (isMoving)
        return;
    isMoving = YES;
    inQueue = 0;
    addedScore = 0;
    
    memset(moveableCol, NO, sizeof(moveableCol));
    memset(moveableRow, NO, sizeof(moveableRow));
    moveableRow[0] = YES;
    
    for (int c = 0; c < 4; c++) {
        int lock = 3;
        for (int r = 3; r >= 0; r--)
            if (numberBoard[r][c] != -1) {
                int i = r + 1;
                while (i < lock + 1 && numberBoard[i][c] == -1)
                    i++;
                if (i == lock + 1) {
                    if (r != lock)
                        [self moveTileFrom:ccp(r, c) To:ccp(lock, c) AndMerge:NO];
                }
                else {
                    if (numberBoard[r][c] == numberBoard[i][c]) {
                        [self moveTileFrom:ccp(r, c) To:ccp(i, c) AndMerge:YES];
                        lock = i - 1;
                    } else if (i != r + 1) {
                        [self moveTileFrom:ccp(r, c) To:ccp(i - 1, c) AndMerge:NO];
                    }
                }
            }
    }
    if (inQueue == 0)
        isMoving = NO;
}

- (void)moveDown
{
    isGameStart = YES;
    if (isMoving)
        return;
    isMoving = YES;
    inQueue = 0;
    
    
    memset(moveableCol, NO, sizeof(moveableCol));
    memset(moveableRow, NO, sizeof(moveableRow));
    moveableRow[3] = YES;
    
    addedScore = 0;
    for (int c = 0; c < 4; c++) {
        int lock = 0;
        for (int r = 0; r < 4; r++)
            if (numberBoard[r][c] != -1) {
                int i = r - 1;
                while (i > lock - 1 && numberBoard[i][c] == -1)
                    i--;
                if (i == lock - 1) {
                    if (r != lock)
                        [self moveTileFrom:ccp(r, c) To:ccp(lock, c) AndMerge:NO];
                }
                else {
                    if (numberBoard[r][c] == numberBoard[i][c]) {
                        [self moveTileFrom:ccp(r, c) To:ccp(i, c) AndMerge:YES];
                        lock = i + 1;
                    } else if (i != r - 1) {
                        [self moveTileFrom:ccp(r, c) To:ccp(i + 1, c) AndMerge:NO];
                    }
                }
            }
    }
    if (inQueue == 0)
        isMoving = NO;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [_bestBar setVisible:YES];
        [_lbScore setString:[NSString stringWithFormat:@"%d", bestScore]];
        [_lbTime setString:[NSString stringWithFormat:@"%0.2f", bestTime]];
    } else if (longPress.state == UIGestureRecognizerStateEnded) {
        [_bestBar setVisible:NO];
        [_lbScore setString:[NSString stringWithFormat:@"%d", score]];
        [_lbTime setString:[NSString stringWithFormat:@"%0.2f", totalTime]];
    }
}

@end
