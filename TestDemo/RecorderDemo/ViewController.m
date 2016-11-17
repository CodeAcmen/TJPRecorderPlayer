//
//  ViewController.m
//  RecorderDemo
//
//  Created by Walkman on 16/10/14.
//  Copyright © 2016年 walkman. All rights reserved.
//

#import "ViewController.h"
#import "TJPRecorderView.h"

@interface ViewController () <TJPRecorderViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =  CGRectMake(self.view.bounds.size.width * 0.5 - 40, 200, 0, 0);
    [button setTitle:@"-点击录音-" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button sizeToFit];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
}

- (void)buttonClick
{
    
    //实例化方法 请把BackgroundView的frame设置为全屏
    //demo中用了SDWebImage  如果项目中也用了 直接将此处的SDWebImage删除即可
    TJPRecorderView * recorderView = [[TJPRecorderView alloc] initWithRecorderViewImage:@"record" andWithBackgroundViewFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    recorderView.delegate = self;
    [self.view addSubview:recorderView];
    
}


#pragma mark - TJPRecorderViewDelegate
- (void)recorderEndWithRecordTime:(NSString *)recordTime andWithRecordFile:(NSString *)recordFile
{
    //点击了提交按钮 回调方法
    NSLog(@"录音时长:%@ --- 录音文件:%@", recordTime, recordFile);
    NSInteger time = [self stringConversionNumber:recordTime];
    
    NSLog(@"录音时长(转换格式之后):%@",
          [NSString stringWithFormat:@"%li'", (long)time]);

    
}


- (NSInteger)stringConversionNumber:(NSString *)time
{
    //判断是否有分钟 此处暂时不判断小时
    //    NSString * hour;
    NSInteger  tmpSecond;
    NSInteger finalTime;
    NSString * secondStr = [time substringFromIndex:4];
    if ([secondStr integerValue] && [secondStr integerValue] < 59) {
        tmpSecond = [secondStr integerValue] * 60;
        finalTime = tmpSecond;
        
        NSString * subTimeStr = [time substringFromIndex:6];
        if ([subTimeStr integerValue] < 10) {
            NSString * tmpStr = [subTimeStr substringFromIndex:1];
            NSInteger  minute = [tmpStr integerValue] + tmpSecond;
            finalTime = minute;
        }else
        {
            NSInteger minute = [subTimeStr integerValue] + tmpSecond;
            finalTime = minute;
        }
    }else {
        NSString * subTimeStr = [time substringFromIndex:6];
        if ([subTimeStr integerValue] < 10) {
            finalTime = [[subTimeStr substringFromIndex:1] integerValue];
        }else
        {
            finalTime = [subTimeStr integerValue];
        }
    }
    return finalTime;
}



@end
