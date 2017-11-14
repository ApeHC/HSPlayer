//
//  HSIJKPlayerControl.h
//  HelloSTV
//
//  Created by HeChuang⌚️ on 2017/11/1.
//  Copyright © 2017年 传输事业部. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSPlayerHeader.h"

@class HSIJKPlayerControl;

@protocol HSPauseOrPlayDelegate <NSObject>

@required
/**
 暂停和播放视图和状态
 
 @param pauseOrPlayView 暂停或者播放视图
 @param state 返回状态
 */
- (void)pauseOrPlayView:(HSIJKPlayerControl *)pauseOrPlayView withState:(BOOL)state;

@end

@interface HSIJKPlayerControl : UIView

@property (nonatomic,strong) UIButton *imageBtn;

@property (nonatomic,weak) id<HSPauseOrPlayDelegate> delegate;

@property (nonatomic,assign,readonly) BOOL state;

@end
