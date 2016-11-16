//
//  XHButton.m
//  TopicPage
//
//  Created by Walkman on 16/1/15.
//  Copyright © 2016年 Walkman. All rights reserved.
//

#import "TJPButton.h"
#import "UIColor+StringExtension.h"
@implementation TJPButton


- (void)XHButtonOfPlayerButtonWithImage:(NSString *)image andButtonTitle:(NSString *)buttonTitle andTitleColor:(UIColor *)titleColor andBackGroundColor:(UIColor *)backgroundColor andRecorderPageButtonStyle:(XHRecorderPageButtonStyle)buttonStyle
{
    [self setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [self setTitle:buttonTitle forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    [self setBackgroundColor:backgroundColor];
    self.tag = buttonStyle;
}



@end
