//
//  Tile.h
//  My2048
//
//  Created by Tô Ngọc Linh on 4/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Tile : CCNode

- (void)setNumber:(int)number;
- (void)fadeOut:(CGFloat)duration;
- (void)fadeInWithDuration:(CGFloat)duration;
- (void)bouncing;

@end
