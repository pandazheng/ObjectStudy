//
//  ViewController.m
//  WebViewDemo
//
//  Created by panda zheng on 15/4/12.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak,nonatomic) UIWebView *webView;

@end

@implementation ViewController
/*
 1. 在地址栏中输入要访问的地址，按下回车，webView加载地址栏中的内容
 2. 在地址栏输入file://开头的地址，加载沙箱中的文件 file://关于.txt
 */
#pragma mark - 设置界面
- (void) setupUI
{
    // 1. 顶部toolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:toolBar];
    
    // 1) TextField可以以UIBarButtonItem的自定义视图的方式加入toolbar
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 6, 200, 32)];
    // 设置边框
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    // 设置垂直对齐
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    // 设置清除按钮
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setDelegate:self];
    
    UIBarButtonItem *addressItem = [[UIBarButtonItem alloc] initWithCustomView:textField];
    
    // 2) 三个按钮
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForward)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    // 将UIBarButtonItem加入toolBar
    [toolBar setItems:@[addressItem,item1,item2,item3]];
    
    // 2. UIWebView
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 416)];
    [self.view addSubview:webView];
    self.webView = webView;
}

#pragma mark - UITextField代理方法
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    // 1. 关闭键盘
    [textField resignFirstResponder];
    
    // 2. 让webView加载地址栏中的内容，如果有内容在加载
    // 关于字符串的比较，是属于消耗性能较大的，在判断字符串是否有内容时，可以使用长度
    // 这样性能更好，此方法适用于所有编程语言
    if (textField.text.length > 0) {
        [self loadContentWithURLString:textField.text];
    }
    
    return YES;
}

#pragma mark - 加载内容
- (void) loadContentWithURLString: (NSString *) urlString
{
    BOOL hasError = YES;
    
    // 针对urlString进行判断
    // 1. 如果是http://开头的，说明是web地址，直接生成请求
    if ([urlString hasPrefix:@"http://"])
    {
        // 1. 建立URL
        [self loadURL:[NSURL URLWithString:urlString]];
        
        hasError = NO;
    }
    else if ([urlString hasPrefix:@"file://"])
    {
        // 2. 如果是file://xxx.txt file://关于.txt开头的，说明要加载沙箱中的文件
        // 1) 从urlString中取出文件名
        NSRange range = [urlString rangeOfString:@"file://"];
        NSString *fileName = [urlString substringFromIndex:range.length];
        NSLog(@"%@", fileName);
        
        // 2) 生成沙箱的url
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        
        // 如果url == nil,说明本地没有文件
        if (url != nil)
        {
            hasError = NO;
        }
        
        // 3) 加载文件
        [self loadURL:url];
    }
    
    // 3. 错误判断，输入地址错误，提示用户
    if (hasError)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"地址错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil , nil];
        [alertView show];
    }
}

- (void) loadURL: (NSURL *) url
{
    // 2. 建立Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. 加载Request
    [self.webView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Actions
#pragma mark 后退
- (void) goBack
{
    NSLog(@"后退");
    [self.webView goBack];
}

#pragma mark 前进
- (void) goForward
{
    NSLog(@"前进");
    [self.webView goForward];
}

#pragma mark 刷新
- (void) refresh
{
    NSLog(@"刷新");
    [self.webView reload];
}

@end
