//
//  ViewController.m
//  DownLoadFile
//
//  Created by panda zheng on 15/4/13.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 下载文件
    [self download];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 下载文件
- (void) download
{
    // 1. NSURL
    NSURL *url = [NSURL URLWithString:@"http://localhost/~apple/itcast/download/iTunesConnect_DeveloperGuide_CN.zip"];
    
    // 2. NSURLRequest
    // 要判断网络服务器上文件的大小，可以使用HTTP的HEAD方法
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 使用HEAD方法，仅获取目标文件的信息，而不做实际的下载工作
    // [request setHTTPMethod:@"HEAD"];
    
    /**
     实现断点续传的思路
     
     HeaderField：头域（请求头部的字段）
     
     可以通过指定rangge的范围逐步地下载指定范围内的数据，待下载完成后，再将这些数据拼接成一个文件
     */
    
    [request setValue:@"bytes=6100000-" forKey:@"range"];
    
    // 3. NSURLConnection
    // 如果要获取文件长度，可以在Response中获取到
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    // 在response的expectedContentLength属性中可以获知要下载文件的文件长度
    NSLog(@"%lld %ld",[response expectedContentLength],(long)data.length);
}

@end
