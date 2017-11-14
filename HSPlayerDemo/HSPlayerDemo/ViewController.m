//
//  ViewController.m
//  HSPlayerDemo
//
//  Created by HeChuang⌚️ on 2017/11/14.
//  Copyright © 2017年 HeChuang. All rights reserved.
//

#import "ViewController.h"
#import "HSIJKPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL * url = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1458715233692shouwang_x264.mp4"];
    HSIJKPlayer * player = [[HSIJKPlayer alloc] initWithMediaURL:url];
    player.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 250);
    player.scalingMode = HSPlayerVideoScalingModeAspectFit;
    player.rate = 1.0;
    [self.view addSubview:player];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
