//
//  HSIJKPlayerToolsView.m
//  HelloSTV
//
//  Created by HeChuang⌚️ on 2017/11/1.
//  Copyright © 2017年 传输事业部. All rights reserved.
//

#import "HSIJKPlayerToolsView.h"

@interface HSIJKPlayerToolsView ()
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * totalTimeLabel;
@property (nonatomic, strong) UISlider * bufferSlider;
@property (nonatomic, strong) UIButton * screenButton;
@property (nonatomic, strong) UISlider * slider;
@end

static NSInteger padding = 8;//组件间隔

@implementation HSIJKPlayerToolsView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setupSubviews];
}

#pragma mark - SetuoSubViews
- (void)setupSubviews{
    [self addSubview:self.timeLabel];
    [self addSubview:self.bufferSlider];
    [self addSubview:self.slider];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.screenButton];
    [self addConstraintsForSubviews];
}

- (void)addConstraintsForSubviews{
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(KToolsTimeLabel_W);
        make.height.mas_equalTo(KToolsTimeLabel_H);
        make.centerY.mas_equalTo(self);
    }];
    [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(padding);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left).offset(-padding);
        make.centerY.equalTo(self);
    }];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.slider.mas_right).offset(padding);
        make.right.mas_equalTo(self.screenButton.mas_left);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(KToolsTimeLabel_W);
        make.height.mas_equalTo(KToolsTimeLabel_H);
    }];
    [self.screenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(self).offset(-padding);
        make.left.mas_equalTo(self.totalTimeLabel.mas_right);
        make.width.height.mas_equalTo(KToolsSlider_H);
    }];
    [self.bufferSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.slider);
    }];
    [self layoutIfNeeded];
}

#pragma mark - Action
/**
 点击Slider调节播放进度

 @param gerture 点击手势
 */
- (void)handleTap:(UITapGestureRecognizer *)gerture{
    CGPoint point = [gerture locationInView:self.slider];
    CGFloat pointX = point.x;
    CGFloat sliderW = self.slider.frame.size.width;
    CGFloat currenValue = pointX/sliderW * self.slider.maximumValue;
    if ([self.delegate respondsToSelector:@selector(controlView:pointSliderLocationWithCurrentValue:)]) {
        [self.delegate controlView:self pointSliderLocationWithCurrentValue:currenValue];
    }
}
/**
 拖拽slider调节播放进度

 @param slider 进度slider
 */
- (void)handleSliderPosition:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlView:draggedPositionWithSlider:)]) {
        [self.delegate controlView:self draggedPositionWithSlider:slider];
    }
}
/**
 全屏Action

 @param button 全屏按钮
 */
- (void)handleLargeBtn:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(controlView:withLargeButton:)]) {
        [self.delegate controlView:self withLargeButton:button];
    }
}

#pragma mark - Set And Get
- (void)setCurrentValue:(CGFloat)currentValue{
    self.slider.value = currentValue;
}

- (CGFloat)currentValue{
    return self.slider.value;
}

- (void)setMinValue:(CGFloat)minValue{
    self.slider.minimumValue = minValue;
}

- (CGFloat)minValue{
    return self.slider.minimumValue;
}

- (void)setMaxValue:(CGFloat)maxValue{
    self.slider.maximumValue = maxValue;
}

- (CGFloat)maxValue{
    return self.slider.maximumValue;
}

- (void)setCurrentTime:(NSString *)currentTime{
    self.timeLabel.text = currentTime;
}

- (NSString *)currentTime{
    return self.timeLabel.text;
}

- (void)setTotalTime:(NSString *)totalTime{
    self.totalTimeLabel.text = totalTime;
}

- (NSString *)totalTime{
    return self.totalTimeLabel.text;
}

- (CGFloat)bufferValue{
    return self.bufferSlider.value;
}

- (void)setBufferValue:(CGFloat)bufferValue{
    self.bufferSlider.value = bufferValue;
}

#pragma mark - lazyload
- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.text = @"00:00";
    }
    return _timeLabel;
}

- (UILabel *)totalTimeLabel{
    if (_totalTimeLabel == nil) {
        _totalTimeLabel = [[UILabel alloc]init];
        _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00";
    }
    return _totalTimeLabel;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc]init];
        [_slider setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
        _slider.continuous = YES;
        self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [_slider addTarget:self action:@selector(handleSliderPosition:) forControlEvents:UIControlEventValueChanged];
        [_slider addGestureRecognizer:self.tapGesture];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
    }
    return _slider;
}

- (UIButton *)screenButton{
    if (_screenButton == nil) {
        _screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _screenButton.contentMode = UIViewContentModeScaleToFill;
        [_screenButton setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
        [_screenButton addTarget:self action:@selector(handleLargeBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton;
}

- (UISlider *)bufferSlider{
    if (_bufferSlider == nil) {
        _bufferSlider = [[UISlider alloc]init];
        [_bufferSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        _bufferSlider.continuous = YES;
        _bufferSlider.minimumTrackTintColor = [UIColor redColor];
        _bufferSlider.minimumValue = 0.f;
        _bufferSlider.maximumValue = 1.f;
        _bufferSlider.userInteractionEnabled = NO;
    }
    return _bufferSlider;
}

@end
