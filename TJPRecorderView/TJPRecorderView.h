//
//  XHActivityView.h
//  ModalViewPractice
//
//  Created by Walkman on 16/1/18.
//  Copyright © 2016年 Walkman. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TJPRecorderViewDelegate

- (void)recorderEndWithRecordTime:(NSString *)recordTime andWithRecordFile:(NSString *)recordFile;
@end

@interface TJPRecorderView : UIView

@property (nonatomic, weak) id<TJPRecorderViewDelegate> delegate;

/**
 *  初始化方法
 *
 *  @param recordImage 录音界面显示的image
 *  @param frame       背景的frame   default is full screen
 *
 */
- (instancetype)initWithRecorderViewImage:(NSString *)recordImage andWithBackgroundViewFrame:(CGRect)frame;



/**
 *  删除录音文件
 */
- (void)removeRecorderFile;

@end
