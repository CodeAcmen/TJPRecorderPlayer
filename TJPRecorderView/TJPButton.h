//
//  XHButton.h
//  TopicPage
//
//  Created by Walkman on 16/1/15.
//  Copyright © 2016年 Walkman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XHRecorderPageButtonPlay = 0,
    XHRecorderPageButtonSure,
    XHRecorderPageButtonRepet
}XHRecorderPageButtonStyle;


@interface TJPButton : UIButton


/**
 *  @brief 录音页面按钮
 *
 *  @param image           @brief buttonImage
 *  @param buttonTitle     @brief buttonTitle
 *  @param titleColor      @brief titleColor
 *  @param backgroundColor @brief backgroundColor
 */
- (void)XHButtonOfPlayerButtonWithImage:(NSString *)image andButtonTitle:(NSString *)buttonTitle andTitleColor:(UIColor *)titleColor andBackGroundColor:(UIColor *)backgroundColor andRecorderPageButtonStyle:(XHRecorderPageButtonStyle)buttonStyle;





@end
