//
//  HSIJKPlayer.m
//  HelloSTV
//
//  Created by HeChuang⌚️ on 2017/10/26.
//  Copyright © 2017年 HeChuang. All rights reserved.
//

#import "HSIJKPlayer.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <Masonry.h>

@interface HSIJKPlayer ()
@property (nonatomic, strong) UIActivityIndicatorView * activityView;
@property (nonatomic, strong) HSIJKPlayerToolsView * BottomBarView;
@property (nonatomic, strong) HSIJKPlayerControl * ControlPlayView;
@property (nonatomic, strong) NSTimer * playTimer;
@property (nonatomic, strong) UIView * BackgroundView;
@property (nonatomic, strong) id <IJKMediaPlayback> player;
@end

static NSInteger count = 0;//用于计时, 5s隐藏工具栏

@implementation HSIJKPlayer

- (instancetype)initWithMediaURL:(NSURL *)url{
    if (self == [super init]) {
        [self setupPlayerWithURL:url];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self CreateUI];
}

- (void)CreateUI{
    self.backgroundColor = [UIColor clearColor];
    [self.activityView startAnimating];
    [self addBackgroundView];
    [self addPlayerView];
    [self addGestureEvent];
    [self addPlayOrPauseButton];
    [self addBottomBarView];
    [self addLoadView];
}

- (void)setupPlayerWithURL:(NSURL *)url{
    IJKFFOptions * optios = [IJKFFOptions optionsByDefault];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:optios];
    self.player.view.frame = self.bounds;
    self.player.view.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.player.scalingMode = IJKMPMovieScalingModeFill;
    self.player.shouldAutoplay = NO;
    [self installMovieNotificationObservers];
    [self.player prepareToPlay];
}

#pragma mark - AddNotification
- (void)installMovieNotificationObservers{
    //播放网络改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    //视频完成播放
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    //播放准备完成
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    //播放状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    //视频解码器打开
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackVideoDecoderOpen:)
                                                 name:IJKMPMoviePlayerVideoDecoderOpenNotification
                                               object:_player];
    //渲染第一帧视频
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFirstVideoFrameRendered:)
                                                 name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification
                                               object:_player];
    //渲染第一帧音频
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFirstAudioFrameRendered:)
                                                 name:IJKMPMoviePlayerFirstAudioFrameRenderedNotification
                                               object:_player];
    //设备方向改变
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

#pragma mark - RemoveNotification
- (void)removeMovieNotificationObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerVideoDecoderOpenNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerFirstAudioFrameRenderedNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

#pragma mark - NSTimerAction
- (void)updatePlayTime{
    if (self.player.isPlaying){
        self.BottomBarView.currentValue = self.player.currentPlaybackTime;
        self.BottomBarView.currentTime = [self TimeIntervalTransformTimeStringWithTime:self.player.currentPlaybackTime];
        if (count >= 5) {
            [self setSubViewIsHide:YES];
        } else{
            [self setSubViewIsHide:NO];
        }
        count += 1;
    }
}

#pragma mark - HSIJKPlayerBottomBarDelegate
- (void)controlView:(HSIJKPlayerToolsView *)controlView draggedPositionWithSlider:(UISlider *)slider{
    count = 0;
    NSTimeInterval currentTime = slider.value / slider.maximumValue * self.player.duration;
    self.player.currentPlaybackTime = currentTime;
}

- (void)controlView:(HSIJKPlayerToolsView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value{
    count = 0;
    self.player.currentPlaybackTime = value;
}

- (void)controlView:(HSIJKPlayerToolsView *)controlView withLargeButton:(UIButton *)button{
    count = 0;
    if (KHSIJKPlayerUISIZE.width < KHSIJKPlayerUISIZE.height) {
        //此时,点击之前为竖屏, 想要切换全屏
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }else {
        //此时,点击之前为全屏, 想要切换竖屏
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

#pragma mark - HSPauseOrPlayDelegate
- (void)pauseOrPlayView:(HSIJKPlayerControl *)pauseOrPlayView withState:(BOOL)state{
    count = 0;
    if (state) {
        [self play];
    } else {
        [self pause];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[HSIJKPlayerToolsView class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Notification
- (void)loadStateDidChange:(NSNotification *)notification{
    IJKMPMovieLoadState loadState = _player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        [self.activityView stopAnimating];
        _isPlaying = YES;
        self.ControlPlayView.imageBtn.hidden = NO;
        NSLog(@"IJKMPMoviePlayerLoadStateDidChangeNotification: 通过");
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        [self.activityView startAnimating];
        _isPlaying = NO;
        self.ControlPlayView.imageBtn.hidden = YES;
        NSLog(@"IJKMPMoviePlayerLoadStateDidChangeNotification: 停滞");
    } else {
        [self.activityView startAnimating];
        _isPlaying = NO;
        self.ControlPlayView.imageBtn.hidden = NO;
        NSLog(@"IJKMPMoviePlayerLoadStateDidChangeNotification: unknow");
    }
}

- (void)moviePlayBackFinish:(NSNotification *)notification{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"IJKMPMoviePlayerPlaybackDidFinishNotification: 播放结束");
            break;
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"IJKMPMoviePlayerPlaybackDidFinishNotification: 退出播放");
            break;
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"IJKMPMoviePlayerPlaybackDidFinishNotification: 播放错误");
            break;
        default:
            NSLog(@"IJKMPMoviePlayerPlaybackDidFinishNotification: unknow");
            break;
    }
    [self setSubViewIsHide:NO];
    count = 0;
    [self.ControlPlayView.imageBtn setSelected:NO];
    self.player.currentPlaybackTime = 0;
    self.BottomBarView.currentValue = self.player.currentPlaybackTime;
    self.BottomBarView.currentTime = @"00:00";
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification *)notification{
    self.BottomBarView.totalTime = [self TimeIntervalTransformTimeStringWithTime:self.player.duration];
    self.BottomBarView.maxValue = self.player.duration;
    NSLog(@"IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification: 准备状态改变");
}

- (void)moviePlayBackStateDidChange:(NSNotification *)notification{
    [self.playTimer fire];
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:{
            _status = HSPlayerStatusStoped;
            NSLog(@"IJKMPMoviePlayerPlaybackStateDidChangeNotification: 停止");
        }
            break;
        case IJKMPMoviePlaybackStatePlaying:{
            _status = HSPlayerStatusPlaying;
            NSLog(@"IJKMPMoviePlayerPlaybackStateDidChangeNotification: 播放");
        }
            break;
        case IJKMPMoviePlaybackStatePaused:{
            _status = HSPlayerStatusPaused;
            NSLog(@"IJKMPMoviePlayerPlaybackStateDidChangeNotification: 暂停");
        }
            break;
        case IJKMPMoviePlaybackStateInterrupted:{
            _status = HSPlayerStatusInterrupted;
            NSLog(@"IJKMPMoviePlayerPlaybackStateDidChangeNotification: 中断");
        }
            break;
        case IJKMPMoviePlaybackStateSeekingForward:{
            _status = HSPlayerStatusSeekingForward;
            NSLog(@"IJKMPMoviePlayerPlaybackStateDidChangeNotification: 前播");
        }
            break;
        case IJKMPMoviePlaybackStateSeekingBackward:{
            _status = HSPlayerStatusSeekingBackward;
            NSLog(@"IJKMPMoviePlayerPlaybackStateDidChangeNotification: 回播");
        }
            break;
        default:
            _status = HSPlayerStatusUnknow;
            NSLog(@"IJKMPMoviePlayerPlaybackStateDidChangeNotification: unknow");
            break;
    }
}

- (void)moviePlayBackVideoDecoderOpen:(NSNotification *)notification{
    NSLog(@"IJKMPMoviePlayerVideoDecoderOpenNotification: 解码器打开");
}

- (void)moviePlayBackFirstVideoFrameRendered:(NSNotification *)notification{
    NSLog(@"IJKMPMoviePlayerFirstVideoFrameRenderedNotification: 渲染第一帧视频");
}

- (void)moviePlayBackFirstAudioFrameRendered:(NSNotification *)notification{
    NSLog(@"IJKMPMoviePlayerFirstAudioFrameRenderedNotification: 渲染第一帧音频");
}

#pragma mark - deviceOrientationDidChange
- (void)deviceOrientationDidChange:(NSNotification *)notification{
    UIInterfaceOrientation _interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (_interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"竖屏 -> 横屏");
            _isFullScreen = YES;
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^{
                [self.BackgroundView removeFromSuperview];
                [[UIApplication sharedApplication].keyWindow addSubview:self.BackgroundView];
                [self.BackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo([UIApplication sharedApplication].keyWindow);
                }];
                [self.BottomBarView layoutIfNeeded];
            } completion:nil];
        }
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"横屏 -> 竖屏");
            _isFullScreen = NO;
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^{
                [self.BackgroundView removeFromSuperview];
                [self addSubview:self.BackgroundView];
                [self.BackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self);
                }];
                [self layoutIfNeeded];
            } completion:nil];
        }
        case UIInterfaceOrientationUnknown:
        NSLog(@"UIInterfaceOrientationUnknown");
        break;
    }
}

#pragma mark - 屏幕旋转
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight||orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
        // 设置倒立
    }
}

#pragma mark - AddView
- (void)addBackgroundView{
    [self addSubview:self.BackgroundView];
    [self.BackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)addPlayerView{
    [self.BackgroundView addSubview:self.player.view];
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.BackgroundView);
    }];
}

- (void)addGestureEvent{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    tap.delegate = self;
    [self.BackgroundView addGestureRecognizer:tap];
}

- (void)handleTapAction:(UITapGestureRecognizer *)gesture{
    [self setSubViewIsHide:NO];
    count = 0;
}

- (void)addPlayOrPauseButton{
    [self.BackgroundView addSubview:self.ControlPlayView];
    [self.ControlPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.BackgroundView);
    }];
    [self layoutIfNeeded];
}

- (void)addBottomBarView{
    [self.BackgroundView addSubview:self.BottomBarView];
    [self.BottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.BackgroundView);
        make.height.mas_equalTo(@44);
    }];
    [self layoutIfNeeded];
}

- (void)addLoadView{
    [self.BackgroundView addSubview:self.activityView];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@80);
        make.center.mas_equalTo(self.BackgroundView);
    }];
}

#pragma mark - lazyload
- (NSTimer *)playTimer{
    if (_playTimer == nil) {
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(updatePlayTime)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    return _playTimer;
}

- (UIActivityIndicatorView *)activityView{
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.hidesWhenStopped = YES;
    }
    return _activityView;
}

- (HSIJKPlayerToolsView *)BottomBarView{
    if (_BottomBarView == nil) {
        _BottomBarView = [[HSIJKPlayerToolsView alloc] init];
        _BottomBarView.delegate = self;
        _BottomBarView.backgroundColor = [UIColor clearColor];
        [_BottomBarView.tapGesture requireGestureRecognizerToFail:self.ControlPlayView.imageBtn.gestureRecognizers.firstObject];
    }
    return _BottomBarView;
}

- (HSIJKPlayerControl *)ControlPlayView{
    if (_ControlPlayView == nil) {
        _ControlPlayView = [[HSIJKPlayerControl alloc] init];
        _ControlPlayView.delegate = self;
        _ControlPlayView.backgroundColor = [UIColor clearColor];
    }
    return _ControlPlayView;
}

- (UIView *)BackgroundView{
    if (_BackgroundView == nil) {
        _BackgroundView = [[UIView alloc] init];
        _BackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _BackgroundView;
}

#pragma mark - Set&Get
- (CGFloat)rate{
    return self.player.playbackRate;
}

- (void)setRate:(CGFloat)rate{
    self.player.playbackRate = rate;
}

- (void)setScalingMode:(HSPlayerVideoScalingMode)scalingMode{
    switch (scalingMode) {
        case HSPlayerVideoScalingModeNone:
            self.player.scalingMode = IJKMPMovieScalingModeNone;
            break;
        case HSPlayerVideoScalingModeAspectFit:
            self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
            break;
        case HSPlayerVideoScalingModeAspectFill:
            self.player.scalingMode = IJKMPMovieScalingModeAspectFill;
            break;
        case HSPlayerVideoScalingModeFill:
            self.player.scalingMode = IJKMPMovieScalingModeFill;
            break;
    }
}

#pragma mark - Play/Pause/Stop
- (void)play{
    if (self.player) {
        [self.player play];
    }
}

- (void)pause{
    if (self.player) {
        [self.player pause];
    }
}

- (void)stop{
    [self.playTimer invalidate];
    [self.player shutdown];
    self.player = nil;
    self.playTimer = nil;
    self.BottomBarView.currentTime = @"00:00";
    self.BottomBarView.totalTime = @"00:00";
    [self removeFromSuperview];
    [self removeMovieNotificationObservers];
}

#pragma mark - HideSubView
- (void)setSubViewIsHide:(BOOL)hide{
    self.BottomBarView.hidden = hide;
    self.ControlPlayView.hidden = hide;
}

#pragma mark - TimeDateTransfrom
- (NSString *)TimeIntervalTransformTimeStringWithTime:(NSTimeInterval)interval{
    NSInteger intTime = interval + 0.5;
    return [NSString stringWithFormat:@"%02d:%02d", (int)(intTime / 60), (int)(intTime % 60)];
}

@end
