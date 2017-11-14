//
//  HSIJKPlayerControl.m
//  HelloSTV
//
//  Created by HeChuang⌚️ on 2017/11/1.
//  Copyright © 2017年 传输事业部. All rights reserved.
//

#import "HSIJKPlayerControl.h"

@implementation HSIJKPlayerControl

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imageBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.imageBtn setShowsTouchWhenHighlighted:YES];
    [self.imageBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [self.imageBtn addTarget:self action:@selector(handleImageTapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.imageBtn];
    [self.imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)handleImageTapAction:(UIButton *)button{
    button.selected = !button.selected;
    self.state = button.isSelected ? YES : NO;
    if ([self.delegate respondsToSelector:@selector(pauseOrPlayView:withState:)]) {
        [self.delegate pauseOrPlayView:self withState:self.state];
    }
}

- (void)setState:(BOOL)state{
    self.imageBtn.selected = state;
}

- (BOOL)state{
    return self.imageBtn.selected;
}

@end
