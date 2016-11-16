//
//  XHActivityView.m
//  ModalViewPractice
//
//  Created by Walkman on 16/1/18.
//  Copyright © 2016年 Walkman. All rights reserved.
//

#import "TJPRecorderView.h"
#import <AVFoundation/AVFoundation.h>
#import "TJPButton.h"
#import "UIImage+GIF.h"
#import "UIColor+StringExtension.h"



#define SCREEN_WIDTH                            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT                           [UIScreen mainScreen].bounds.size.height
#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]
#define TEXT_COLOR                              [UIColor colorWithRed:57 / 255.0f green:58 / 255.0f blue:60 / 255.0f alpha:1]
#define LAYER_BORDER_COLOR                      [UIColor colorWithRed:235 / 255.0f green:239 / 255.0f blue:242 / 255.0f alpha:1].CGColor
#define ACTIONSHEET_BACKGROUNDCOLOR             [UIColor whiteColor]
#define WS(weakSelf)        __weak __typeof(&*self)weakSelf = self;


#define ANIMATE_DURATION                        0.25f
#define TIME_INTERVAL_HEIGHT                    15
#define TIME_LABEL_HEIGHT                       35
#define TIME_LABEL_WIDTH                        80
#define RECORD_INTERVAL_HEIGHT                  200
#define RECORD_LABEL_HEIGHT                     36
#define RECORD_LABEL_WIDTH                      130
#define ACTIVITY_HEIGHT                         260

NSString * const timeStr = @"00:00:00";
NSString * const labelTitle = @"按住录音";




@interface TJPRecorderView () <AVAudioPlayerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIView * actionSheetView;
@property (nonatomic, assign) CGFloat activityHeight;
@property (nonatomic, assign) BOOL isHadTimeTitle;
@property (nonatomic, assign) BOOL isHadRecorderButton;
@property (nonatomic, assign) BOOL isHadRecordeLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIImageView * recordImageView;
@property (nonatomic, strong) UILabel * recordeLabel;
@property (nonatomic, strong) TJPButton * playBtn;
@property (nonatomic, strong) TJPButton * sureBtn;
@property (nonatomic, strong) TJPButton * repetBtn;
@property (nonatomic, strong) NSString * image;


//录音
@property (nonatomic, strong) AVAudioRecorder * audioRecorder;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSString * recordingFilePath;
@property (nonatomic, strong) NSString * sessionCategory;


//播放
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;
@property (nonatomic, strong) NSString * finalTimeStr;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isHeadPhone;

@end


@implementation TJPRecorderView
{
    NSTimer * _timer;
    
    NSUInteger _hour;
    NSUInteger _minite;
    NSUInteger _second;
    NSUInteger _count;
    BOOL _isRunning;
}

#pragma mark - 实例化方法
- (instancetype)initWithRecorderViewImage:(NSString *)recordImage andWithBackgroundViewFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.image = recordImage;
        //创建UI
        [self setupUI];
        
        _isHeadPhone = [self isHeadsetPluggedIn];
        
        //创建录音文件
        [self createRecordFile];
        //添加定时器
        [self createTimer];
       
    }
    return self;
}


//销毁timer
- (void)dealloc
{
    NSLog(@"TJPRecorderViewDealloc");
    if (_timer) {
        [_timer invalidate];
    }
}


#pragma mark - UI
- (void)setupUI
{
    //背景视图层
    self.backgroundColor = WINDOW_COLOR;
    self.userInteractionEnabled = YES;
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self addGestureRecognizer:tapGesture];
    
    
    //actionSheetview
    [self createSubView];
    
    
    //初始化相关控件
    [self createButtonWithTimeTitle:timeStr
                   recordLabelTitle:labelTitle
            andRecordImageViewImage:self.image];

    
}


- (void)createSubView
{
    self.isHadTimeTitle = NO;
    self.isHadRecorderButton = NO;
    self.isHadRecordeLabel = NO;
    
    //初始化ACtionView的高度
    self.activityHeight = ACTIVITY_HEIGHT;
    
    //生成ActionSheetView
    self.actionSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
    self.actionSheetView.backgroundColor = ACTIONSHEET_BACKGROUNDCOLOR;
    
    //添加手势
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedactionSheetView)];
    [self.actionSheetView addGestureRecognizer:tapGesture];
    [self addSubview:self.actionSheetView];
}



//初始化相关控件
- (void)createButtonWithTimeTitle:(NSString *)title recordLabelTitle:(NSString *)recordLabTitle andRecordImageViewImage:(NSString *)recordImage
{
    //时间label
    if (title) {
        self.isHadTimeTitle = YES;
        _timeLabel = [self createTimeLabelWithTitle:title];
        [self.actionSheetView addSubview:_timeLabel];
    }
    
    //录音ImageView
    if (recordImage) {
        self.isHadRecorderButton = YES;
        _recordImageView = [self createRecordButtonWithImage:recordImage];
        [self.actionSheetView addSubview:_recordImageView];
    }
    
    //录音label
    if (recordLabTitle) {
        [self createRecordLabelWithRecordLabTitle:recordLabTitle];
    }
    WS(weakSelf)
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [weakSelf.actionSheetView setFrame:CGRectMake(0, SCREEN_HEIGHT - weakSelf.activityHeight, SCREEN_WIDTH, weakSelf.activityHeight)];
    }];
}



//布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    
}


#pragma mark - 判断当前音频设备状态
- (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription * route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription * desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            NSLog(@"%@", desc);
            return YES;
        }
    }
    return NO;
}



#pragma mark - 创建储存录音文件
- (void)createRecordFile
{
    //m4a格式的文件
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    _recordingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",fileName]];
//    NSLog(@"%@", _recordingFilePath);
    //设置后台播放
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    //判断后台有没有播放
    if (!session) {
        NSLog(@"Error creating session:%@", sessionError.description);
    }else {
        [session setActive:YES error:nil];
    }
}



//删除录音文件
- (void)removeRecorderFile
{
    [[NSFileManager defaultManager] removeItemAtPath:_recordingFilePath error:nil];
}



#pragma mark - 长按手势触发事件
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) { //手势开始
        //长按手势触发改变UI
        [self gestureBeginWithChangeUI];
        //开始计时器
        [_timer setFireDate:[NSDate distantPast]];
        //开始录音
        [self recordBegin];
        
    }else if(longPress.state == UIGestureRecognizerStateEnded) {//手势结束
        if (_second < 1) { //手势触发小于1s
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"录音时间过短"
                                                                 message:nil
                                                                delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            //结束计时器
            [_timer setFireDate:[NSDate distantFuture]];
            _count = 0;
            _isRecording = NO;
            [_recordeLabel removeFromSuperview];
            [self createRecordLabelWithRecordLabTitle:labelTitle];
            _timeLabel.text = timeStr;
            _recordImageView.image = [UIImage imageNamed:self.image];
            //移除录音
            [self removeRecorderFile];
        }else{
            //结束录音
            [self.audioRecorder stop];
            //结束计时器
            [_timer setFireDate:[NSDate distantFuture]];
            //更新UI
            [self gestureEndWithUpDateUI];
            _finalTimeStr = _timeLabel.text;
        }
        
    }
}


#pragma mark - 录音相关
- (void)recordBegin
{
    _isRecording = YES;
    _isPlaying = NO;
    //录音属性相关
    NSMutableDictionary *recordSetting  = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    //判断录音文件是否为空
    if ([[NSFileManager defaultManager] fileExistsAtPath:_recordingFilePath])
    {
        [self removeRecorderFile];
    }
    
    _sessionCategory = [[AVAudioSession sharedInstance] category];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    
    //开始录音
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordingFilePath] settings:recordSetting error:nil];
    //准备记录录音
    [self.audioRecorder prepareToRecord];
    //启动或者恢复记录的录音文件
    [self.audioRecorder record];
}

- (void)playOfRecordForAutomic
{
    _isPlaying = YES;

    _sessionCategory = [[AVAudioSession sharedInstance] category];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSError * playError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordingFilePath] error:&playError];
    if (!self.audioPlayer) {
        NSLog(@"%@", playError.description);
    }
    self.audioPlayer.delegate = self;
}

//当播放结束后调用这个方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //按钮标题变为播放
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_timer setFireDate:[NSDate distantFuture]];
    _isPlaying = NO;

}



#pragma mark - 定时器相关
- (void)createTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerGo) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    _isRunning = NO;
}



- (void)timerGo
{
    //改变Label的文本
    _second = ++_count / 10 % 60;
    _minite = _count / 10 / 60 % 60;
    _hour = _count / 10 / 60 / 60 % 24;
    _timeLabel.text = [NSString stringWithFormat:@"%.2lu:%.2lu:%.2lu", _hour, _minite, _second];
    
}

#pragma mark - 更新改变UI相关
//长按手势触发改变UI
- (void)gestureBeginWithChangeUI
{
    _recordImageView.image = [UIImage sd_animatedGIFNamed:@"recording_automic@2x"];
    //改变颜色 红底白字
    _recordeLabel.backgroundColor = [UIColor colorWithHexString:@"Fb586c"];
    _recordeLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
    _recordeLabel.layer.borderColor = [UIColor colorWithHexString:@"Fb586c"].CGColor;
}


//长按手势结束更新UI
- (void)gestureEndWithUpDateUI
{
    //先移除之前的控件
    [_recordImageView removeFromSuperview];
    [_recordeLabel removeFromSuperview];
    
    //播放button
    _playBtn = [TJPButton buttonWithType:UIButtonTypeCustom];
    [_playBtn XHButtonOfPlayerButtonWithImage:@"play"
                               andButtonTitle:nil
                                andTitleColor:nil
                           andBackGroundColor:nil
                   andRecorderPageButtonStyle:XHRecorderPageButtonPlay];
    _playBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 40, CGRectGetMaxY(_timeLabel.frame) + 25, 80, 80);
    [_playBtn addTarget:self action:@selector(recordeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionSheetView addSubview:_playBtn];
    //提交button
    _sureBtn = [TJPButton buttonWithType:UIButtonTypeCustom];
    [_sureBtn XHButtonOfPlayerButtonWithImage:@"nil"
                               andButtonTitle:@"提 交"
                                andTitleColor:[UIColor whiteColor]
                           andBackGroundColor:[UIColor colorWithHexString:@"Fb586c"]
                   andRecorderPageButtonStyle:XHRecorderPageButtonSure];
    _sureBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 65, CGRectGetMaxY(_playBtn.frame) + 15, RECORD_LABEL_WIDTH, RECORD_LABEL_HEIGHT);
    //RECORD_LABEL_HEIGHT  提交按钮 和之前的录音label同宽 36
    [_sureBtn addTarget:self action:@selector(recordeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _sureBtn.clipsToBounds = YES;
    _sureBtn.layer.cornerRadius = RECORD_LABEL_HEIGHT / 2;
    _sureBtn.layer.borderWidth = 1;
    _sureBtn.layer.borderColor = [UIColor colorWithHexString:@"Fb586c"].CGColor;
    [self.actionSheetView addSubview:_sureBtn];
    
    //重录button
    _repetBtn = [TJPButton buttonWithType:UIButtonTypeCustom];
    [_repetBtn XHButtonOfPlayerButtonWithImage:@"nil"
                                andButtonTitle:@"重 录"
                                 andTitleColor: TEXT_COLOR
                            andBackGroundColor:[UIColor whiteColor]
                    andRecorderPageButtonStyle:XHRecorderPageButtonRepet];
    _repetBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 65, CGRectGetMaxY(_sureBtn.frame) + 5, RECORD_LABEL_WIDTH, RECORD_LABEL_HEIGHT);
    [_repetBtn addTarget:self action:@selector(recordeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _repetBtn.clipsToBounds = YES;
    _repetBtn.layer.cornerRadius = RECORD_LABEL_HEIGHT / 2;
    _repetBtn.layer.borderWidth = 1;
    _repetBtn.layer.borderColor = LAYER_BORDER_COLOR;
    [self.actionSheetView addSubview:_repetBtn];
}

#pragma mark - 录音界面按钮点击事件
- (void)recordeButtonClicked:(UIButton *)button
{
    switch (button.tag) {
        case XHRecorderPageButtonPlay:
            //播放
        {
            if (_isPlaying == NO) {
                //开始播放
                _isPlaying = YES;
                _count = 0;
                [_timer setFireDate:[NSDate distantPast]];
                [self playOfRecordForAutomic];
                [self.audioPlayer play];
                [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                
            }else {
                _timeLabel.text = _finalTimeStr;
                _isPlaying = NO;
                [self.audioPlayer pause];
                [_timer setFireDate:[NSDate distantFuture]];
                [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                
            }
        }
            break;
        case XHRecorderPageButtonSure:
            //提交
        {
            _isRecording = NO;
//            //获取录音时长
//            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordingFilePath] error:nil];
//            
//            
//            NSTimeInterval time = self.audioPlayer.duration;
//            self.finalTimeStr = [NSString stringWithFormat:@"%02li:%02li:%02li",
//                                                    
//                                                    lround(floor(time / 3600.f)) % 100,
//                                                    
//                                                    lround(floor(time / 60.f)) % 60,
//                                                    
//                                                    lround(floor(time / 1.f)) % 60];

            [self.delegate recorderEndWithRecordTime:_finalTimeStr andWithRecordFile:_recordingFilePath];
            [self tappedCancel];
            
        }
            break;
        case XHRecorderPageButtonRepet:
            //重录
        {
            UIAlertView * repetAlert = [[UIAlertView alloc] initWithTitle:@"是否重新录音"
                                                                  message:@"如果重新录音,之前录音会被删除"
                                                                 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [repetAlert show];
            
        }
            break;
        default:
            break;
    }
}

- (void)tappedCancel
{
    if (_isRecording == YES) {
        UIAlertView * cancelAlertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                   message:@"您当前录音还未提交"
                                                                  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [cancelAlertView show];
    }else
    {
        [UIView animateWithDuration:ANIMATE_DURATION animations:^{
            [self setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self removeFromSuperview];
            }
        }];
    }
    
}



- (void)tappedactionSheetView
{
    //
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
        {
            //停止录音
            [self.audioPlayer stop];
            //移除录音
            [self removeRecorderFile];
            //重载UI
            [self reloadRecordView];
            _isRecording = NO;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 重载UI
- (void)reloadRecordView
{
    [_timeLabel removeFromSuperview];
    [_playBtn removeFromSuperview];
    [_sureBtn removeFromSuperview];
    [_repetBtn removeFromSuperview];
    _count = 0;
    _second = 0;
    _hour = 0;
    [self createButtonWithTimeTitle:timeStr
                   recordLabelTitle:labelTitle
            andRecordImageViewImage:self.image];
    
}

#pragma mark - 创建控件的方法
- (UILabel *)createTimeLabelWithTitle:(NSString *)timeTitle
{
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, TIME_INTERVAL_HEIGHT, TIME_LABEL_WIDTH, TIME_LABEL_HEIGHT)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:16];
    timeLabel.text = timeTitle;
    timeLabel.textColor = TEXT_COLOR;
    return timeLabel;
}


- (void)createRecordLabelWithRecordLabTitle:(NSString *)recordLabTitle
{
    self.isHadRecordeLabel = YES;
    _recordeLabel = [self createRecordeLabelWithTitle:recordLabTitle];
    UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPressGesture.minimumPressDuration = 0.3;
    [_recordeLabel addGestureRecognizer:longPressGesture];
    [self.actionSheetView addSubview:_recordeLabel];
    
}

- (UIImageView *)createRecordButtonWithImage:(NSString *)recordImage
{
    UIImageView * recordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, CGRectGetMaxY(_timeLabel.frame) + 30, 80, 80)];
    recordImageView.image = [UIImage imageNamed:recordImage];
    return recordImageView;
    
}

- (UILabel *)createRecordeLabelWithTitle:(NSString *)recordTitle
{
    UILabel * recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 65, RECORD_INTERVAL_HEIGHT, RECORD_LABEL_WIDTH, RECORD_LABEL_HEIGHT)];
    recordLabel.textAlignment = NSTextAlignmentCenter;
    recordLabel.font = [UIFont boldSystemFontOfSize:15];
    recordLabel.text = recordTitle;
    recordLabel.clipsToBounds = YES;
    recordLabel.layer.borderWidth = 1;
    recordLabel.userInteractionEnabled = YES;
    recordLabel.layer.cornerRadius = RECORD_LABEL_HEIGHT / 2;
    recordLabel.layer.borderColor = LAYER_BORDER_COLOR;
    recordLabel.textColor = TEXT_COLOR;
    
    return recordLabel;
}







@end
