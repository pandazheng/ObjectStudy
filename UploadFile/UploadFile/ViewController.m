//
//  ViewController.m
//  UploadFile
//
//  Created by panda zheng on 15/4/13.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak,nonatomic) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //定义ImageView并设置图像
    UIImage *image = [UIImage imageNamed:@"头像1.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    [imageView setFrame:CGRectMake(60, 20, 200, 200)];
    [self.view addSubview:imageView];
    
    
    self.imageView = imageView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(60, 240, 200, 40)];
    [button setTitle:@"upload" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(uploadImage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 上传图像
- (void) uploadImage
{
    // 思路：是需要使用HTTP的POST方法上传文件
    // 调用的URL是http://localhost/~apple/itcast/upload.php
    // 数据体的参数名：file
    
    
    // 1. 建立NSURL
    NSURL *url = [NSURL URLWithString:@"http://localhost/~apple/itcast/upload.php"];
    
    // 2. 建立NSMutableURLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 1) 设置request的属性，设置方法
    [request setHTTPMethod:@"POST"];
    
    // 2) 设置数据体
    
    // 1> 设置boundary的字符串，以便复用
    NSString *boundary = @"uploadBoundary";
    // 2> 头部字符串
    NSMutableString *startStr = [NSMutableString string];
    [startStr appendFormat:@"--%@\n",boundary];
    [startStr appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"upload.png\"\n"];
    [startStr appendString:@"Content-Type: image/png\n\n"];
    
    // 3> 尾部字符串
    NSMutableString *endStr = [NSMutableString string];
    [endStr appendFormat:@"--%@\n", boundary];
    [endStr appendString:@"Content-Disposition: form-data; name=\"submit\"\n\n"];
    [endStr appendString:@"Submit\n"];
    [endStr appendFormat:@"--%@--", boundary];
    
    // 4> 拼接数据体
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[startStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    [bodyData appendData:imageData];
    
    [bodyData appendData:[endStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:bodyData];
    
    // 5> 指定Content-Type，在上传文件时，需要指定Content-Type & Content-Length
    NSString *contentStr = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentStr forHTTPHeaderField:@"Content-Type"];
    
    // 6> 指定Content-Length
    NSUInteger length = [bodyData length];
    [request setValue:[NSString stringWithFormat:@"%ld",(long)length] forHTTPHeaderField:@"Content-Length"];
    
    
    // 3. 使用NSURLConnection的同步方法上传文件，因为需要用户确认文件是否上传成功！
    //    在使用HTTP上传文件时，通常是有大小限制的，一般不会超过2M
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *resultStr = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",resultStr);
}

@end
