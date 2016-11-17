//
//  UIView+TJPExtension.m
//  百思不得姐-practice
//
//  Created by Walkman on 16/9/21.
//  Copyright © 2016年 walkman. All rights reserved.
//

#import "UIView+TJPExtension.h"

@implementation UIView (TJPExtension)

- (CGSize)tjp_size
{
    return self.frame.size;
}

- (void)setTjp_size:(CGSize)tjp_size
{
    CGRect frame = self.frame;
    frame.size = tjp_size;
    self.frame = frame;
}

- (CGFloat)tjp_width
{
    return self.frame.size.width;
}

- (CGFloat)tjp_height
{
    return self.frame.size.height;
}

- (void)setTjp_width:(CGFloat)tjp_width
{
    CGRect frame = self.frame;
    frame.size.width = tjp_width;
    self.frame = frame;
}

- (void)setTjp_height:(CGFloat)tjp_height
{
    CGRect frame = self.frame;
    frame.size.height = tjp_height;
    self.frame = frame;
}


- (CGFloat)tjp_x
{
    return self.frame.origin.x;
}

- (CGFloat)tjp_y
{
    return self.frame.origin.y;
}

- (void)setTjp_x:(CGFloat)tjp_x
{
    CGRect frame = self.frame;
    frame.origin.x = tjp_x;
    self.frame = frame;
    
}

- (void)setTjp_y:(CGFloat)tjp_y
{
    CGRect frame = self.frame;
    frame.origin.y = tjp_y;
    self.frame = frame;
    
}

- (CGFloat)tjp_centerX
{
    return self.center.x;
}

- (void)setTjp_centerX:(CGFloat)tjp_centerX
{
    CGPoint center = self.center;
    center.x = tjp_centerX;
    self.center = center;
}


- (CGFloat)tjp_centerY
{
    return self.center.y;
}

- (void)setTjp_centerY:(CGFloat)tjp_centerY
{
    CGPoint center = self.center;
    center.y = tjp_centerY;
    self.center = center;
}


- (CGFloat)tjp_right
{
//    return self.tjp_x + self.tjp_width;
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)tjp_bottom
{
//    return self.tjp_y + self.tjp_height;
    return CGRectGetMaxY(self.frame);
}

- (void)setTjp_right:(CGFloat)tjp_right
{
    self.tjp_x = tjp_right - self.tjp_width;
}

- (void)setTjp_bottom:(CGFloat)tjp_bottom
{
    self.tjp_y = tjp_bottom - self.tjp_height;
}





@end
