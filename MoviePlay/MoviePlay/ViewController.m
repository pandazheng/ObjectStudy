//
//  ViewController.m
//  MoviePlay
//
//  Created by panda zheng on 15/4/12.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

// 视频播放器
@property (strong,nonatomic) MPMoviePlayerController *player;

@property (strong,nonatomic) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 实例化视频播放器
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"promo_full" withExtension:@"mp4"];
    // 视频播放是流媒体的播放模式，所谓流媒体，就是把视频数据像流水一样，边加载，边播放！
    // 提示，url中如果包含中文，需要添加百分号
    //NSString *urlString = @"http://localhost/~apple/itcast/videos/01.C语言-语法预览.mp4";
    
    //NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    // 1. 设置播放器的大小 (16:9)
    [self.player.view setFrame:CGRectMake(0, 0, 320, 180)];
    
    // 2. 将播放器视图添加到根视图
    [self.view addSubview:self.player.view];
    
    // 3. 播放
    [self.player play];
    
    // 通过通知中心，以观察者模式监听视频播放状态
    // 1) 监听播放状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stateChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    // 2) 监听播放完成
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishedPlay) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    // 3) 视频截图
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(caputerImage:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    
    // 4) 退出全屏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishedPlay) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    // 异步的视频截图，可以在AtTimes指定一个或多个时间
    [self.player requestThumbnailImagesAtTimes:@[@10.0f,@20.0f] timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 200, 160, 90)];
    self.imageView = thumbnailImageView;
    
    [self.view addSubview:thumbnailImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 播放器事件监听
//#pragma mark 退出全屏
//- (void)exitFullScreen
//{
//    NSLog(@"退出全屏");
//}

#pragma mark 视频截图
- (void)caputerImage:(NSNotification *)notification
{
    NSLog(@"截图 %@", notification);
    UIImage *image = notification.userInfo[@"MPMoviePlayerThumbnailImageKey"];
    [self.imageView setImage:image];
}

#pragma mark 播放完成 & 退出全屏
- (void)finishedPlay
{
    NSLog(@"播放完成");
    
    // 如果不使用其他视图控制器播放视频，可以使用此方法
    // 将播放器的视图，从当前视图中删除
    [self.player.view removeFromSuperview];
}

#pragma mark 播放状态变化
/*
 MPMoviePlaybackStateStopped,           停止
 MPMoviePlaybackStatePlaying,           播放
 MPMoviePlaybackStatePaused,            暂停
 MPMoviePlaybackStateInterrupted,       中断
 MPMoviePlaybackStateSeekingForward,    快进
 MPMoviePlaybackStateSeekingBackward    快退
 */
- (void) stateChange
{
    switch (self.player.playbackState) {
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停");
            break;
        case MPMoviePlaybackStatePlaying:
            //设置全屏播放
            [self.player setFullscreen:YES animated:YES];
            
            NSLog(@"播放");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止");
            break;
        default:
            break;
    }
}

@end
