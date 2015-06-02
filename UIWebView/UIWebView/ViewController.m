//
//  ViewController.m
//  UIWebView
//
//  Created by panda zheng on 15/4/12.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"

/*
 WebView加载本地文件可以使用加载数据的方式
 1. NSData 本地文件对应的数据
 2. MIMEType
 3. 编码格式字符串
 4. 相对地址，一般加载本地文件不使用，可以在指定的baseURL中查找相关文件
 
 如果要用UIWebView显示对应的文件，必须知道准确的MIMEType
 但是，不是所有格式的文件都可以通过本地数据的方式加载，即便是知道MIMEType
 
 UIWebView加载内容的三种方式：
 
 1. 加载本地数据文件
 需要制定文件的MIMEType
 编码格式使用@"UTF-8"
 
 2. 加载html字符串
 可以加载全部或者部分hmtl字符串
 
 3. 加载NSURLRequest
 前面两步与NSURLConnection一致
 
 使用HTML5开发应用
 
 优势：
 1. 跨平台
 2. 审批通过之后，就终身不需要审批，只需要在后台自己随时维护即可
 
 弱势：
 1. 没有办法利用硬件资源，加速剂、手势
 2. 性能不好
 
 部分显示html的功能，可以方便制作新闻客户端阅读部分的UI
 */

@interface ViewController ()

@property (weak,nonatomic) UIWebView *webView;

@end

@implementation ViewController

#pragma mark 设置界面
- (void) setupUI
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    //检测所有的数据类型
    [webView setDataDetectorTypes:UIDataDetectorTypeAll];
    
    self.webView = webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"demo.html" ofType:nil];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    
//    NSLog(@"%@",[self mimeType:url]);
//    
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    
//    NSURL *url = [[NSBundle mainBundle]URLForResource:@"iOS6Cookbook.pdf" withExtension:nil];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    [self.webView loadRequest:request];
    //[self loadHTMLString];
    //[self loadPDF];
    //[self loadText];
    [self loadHTML];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 加载html字符串
- (void)loadHTMLString
{
    // HTML5
    // 直接加载HTML字符串，完整的html
    //NSString *str = @"<html><head><title>Hello</title></head><body><h1>Hello</h1><ul><li>123</li><li>321</li><li>1234567</li></ul></body></html>";
    
    // 部分html
    NSString *str1 = @"<h1>Hello</h1><ul><li>123</li><li>321</li><li>1234567</li></ul>";
    [self.webView loadHTMLString:str1 baseURL:nil];
}

#pragma mark - 加载pdf文件
- (void)loadPDF
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"iOS6Cookbook.pdf" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSLog(@"%@", [self mimeType:url]);
    
    // 以二进制数据的形式加载沙箱中的文件
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    [self.webView loadData:data MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil];
}

#pragma mark - 加载本地文本文件
- (void)loadText
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"关于.txt" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSLog(@"%@", [self mimeType:url]);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    [self.webView loadData:data MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:nil];
}

#pragma mark - 加载本地html文件
- (void)loadHTML
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"demo.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSLog(@"%@", [self mimeType:url]);
    
    // 以二进制数据的形式加载沙箱中的文件
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
}


#pragma mark 获取指定URL的MIMEType类型
- (NSString *) mimeType : (NSURL *) url
{
    // 1. NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2. NSURLConnection
    // 从NSURLResponse可以获取到服务器返回的MIMEType
    // 使用同步方法获取MIMEType
    NSURLResponse *response = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    return response.MIMEType;
}

@end
