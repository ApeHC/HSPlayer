//
//  HSIJKPlayer.h
//  HelloSTV
//
//  Created by HeChuang⌚️ on 2017/10/26.
//  Copyright © 2017年 HeChuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSIJKPlayerToolsView.h"
#import "HSIJKPlayerControl.h"

/**
 视频的缩放模式

 - HSPlayerVideoScalingModeNone: 无缩放
 - HSPlayerVideoScalingModeAspectFit: 按比例缩放, 直到一个维度填充合适
 - HSPlayerVideoScalingModeModeAspectFill: 按比例缩放, 填满整个界面, 视频可能被部分裁剪
 - HSPlayerVideoScalingModeModeFill: 非比例缩放,按界面填充
 */
typedef NS_ENUM(NSInteger, HSPlayerVideoScalingMode) {
    HSPlayerVideoScalingModeNone,
    HSPlayerVideoScalingModeAspectFit,
    HSPlayerVideoScalingModeAspectFill,
    HSPlayerVideoScalingModeFill
};

/**
 视频的当前状态

 - HSPlayerStatusStoped: 停止
 - HSPlayerStatusPlaying: 播放
 - HSPlayerStatusPaused: 暂停
 - HSPlayerStatusInterrupted: 中断
 - HSPlayerStatusSeekingForward: 前播
 - HSPlayerStatusSeekingBackward: 回播
 */
typedef NS_ENUM(NSInteger, HSPlayerStatus) {
    HSPlayerStatusStoped,
    HSPlayerStatusPlaying,
    HSPlayerStatusPaused,
    HSPlayerStatusInterrupted,
    HSPlayerStatusSeekingForward,
    HSPlayerStatusSeekingBackward,
    HSPlayerStatusUnknow
};

@interface HSIJKPlayer : UIView<
HSIJKPlayerBottomBarDelegate,
HSPauseOrPlayDelegate,
UIGestureRecognizerDelegate>
//播放状态
@property (nonatomic, assign, readonly) HSPlayerStatus status;
//是否播放
@property (nonatomic, assign, readonly) BOOL isPlaying;
//是否全屏
@property (nonatomic, assign, readonly) BOOL isFullScreen;
//填充模式
@property (nonatomic, assign, readwrite) HSPlayerVideoScalingMode scalingMode;
//播放器速率
@property (nonatomic, assign) CGFloat rate;
//初始化
- (instancetype)initWithMediaURL:(NSURL *)url;
//播放
- (void)play;
//暂停
- (void)pause;
//停止(销毁)
- (void)stop;

@end
