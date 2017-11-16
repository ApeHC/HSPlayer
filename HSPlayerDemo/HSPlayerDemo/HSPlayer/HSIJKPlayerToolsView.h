//
//  HSIJKPlayerToolsView.h
//  HelloSTV
//
//  Created by HeChuang⌚️ on 2017/11/1.
//  Copyright © 2017年 HeChuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSPlayerHeader.h"

#define KToolsTimeLabel_W @50
#define KToolsTimeLabel_H @20
#define KToolsSlider_H @30

@class HSIJKPlayerToolsView;

@protocol HSIJKPlayerBottomBarDelegate <NSObject>
/**
 进度slider'点击'
 
 @param controlView 底栏视图
 @param value 点击位置的Value
 */
- (void)controlView:(HSIJKPlayerToolsView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value;

/**
 进度slider'拖动'
 
 @param controlView 底栏视图
 @param slider slider
 */
- (void)controlView:(HSIJKPlayerToolsView *)controlView draggedPositionWithSlider:(UISlider *)slider;

/**
 全屏
 
 @param controlView 底栏视图
 @param button button
 */
- (void)controlView:(HSIJKPlayerToolsView *)controlView withLargeButton:(UIButton *)button;
@end

@interface HSIJKPlayerToolsView : UIView
/**
 进度当前值
 */
@property (nonatomic, assign) CGFloat currentValue;
/**
 最小值
 */
@property (nonatomic, assign) CGFloat minValue;
/**
 最大值
 */
@property (nonatomic, assign) CGFloat maxValue;
/**
 缓存当前值
 */
@property (nonatomic, assign) CGFloat bufferValue;
/**
 当前时间
 */
@property (nonatomic, copy) NSString * currentTime;
/**
 总时间
 */
@property (nonatomic, copy) NSString * totalTime;
/**
 进度条拖拽手势
 */
@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;

@property (nonatomic, weak) id<HSIJKPlayerBottomBarDelegate> delegate;

@end
