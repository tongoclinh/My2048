//
//  Tile.m
//  My2048
//
//  Created by Tô Ngọc Linh on 4/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Tile.h"

@interface Tile() {
    CCLabelTTF *_number;
}

@end

@implementation Tile

- (void)setNumber:(int)number
{
    //font size
    [_number setString:[NSString stringWithFormat:@"%d", number]];
    
    //just in case... 5 digits
    if (number > 9999)
        [_number setFontSize:20];
    
    //4 digits
    if (number > 999)
        [_number setFontSize:30];
    
    //3 digits
    else if (number > 99)
        [_number setFontSize:40];
    
    //2 digits
    else
        [_number setFontSize:50];
    
    //color
    
    switch (number) {
        case 1 << 1:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(238, 228, 218)]];
            break;
            
        case 1 << 2:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(237, 224, 200)]];
            break;
            
        case 1 << 3:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(242, 177, 121)]];
            break;
            
        case 1 << 4:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(245, 149, 99)]];
            break;
            
        case 1 << 5:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(246, 124, 95)]];
            break;
            
        case 1 << 6:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(246, 94, 59)]];
            break;
            
        case 1 << 7:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(237, 207, 114)]];
            break;
            
        case 1 << 8:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(237, 204, 97)]];
            break;
            
        case 1 << 9:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(237, 200, 80)]];
            break;
            
        case 1 << 10:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(237, 197, 63)]];
            break;
            
        case 1 << 11:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(237, 194, 46)]];
            break;
            
        default:
            [_number setFontColor:[CCColor colorWithCcColor3b:ccc3(60, 58, 50)]];
            break;
    }
}

- (void)fadeOut:(CGFloat)duration
{
    CCActionFadeOut *fade = [CCActionFadeOut actionWithDuration:duration];
    [_number runAction:fade];
}

- (void)bouncing
{
    //effect
    _number.scale = 1.3;
    CCActionScaleTo *scale = [CCActionScaleTo actionWithDuration:0.5 scale:1];
    [_number runAction:[CCActionEaseBounceOut actionWithAction:scale]];
}

@end
