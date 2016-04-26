//
//  popoverViewBackGround.m
//  Homepwner
//
//  Created by Sen on 9/21/15.
//  Copyright © 2015 SLboat. All rights reserved.
//

#import "PopoverViewBackGround.h"

@implementation PopoverViewBackGround

@synthesize arrowDirection;
@synthesize arrowOffset;

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect {
    // Drawing code
   }
 */

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

+ (CGFloat)arrowHeight
{
    return 35;
}

+ (CGFloat)arrowBase
{
    return 20;
}

@end
