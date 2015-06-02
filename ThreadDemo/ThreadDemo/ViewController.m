//
//  ViewController.m
//  ThreadDemo
//
//  Created by panda zheng on 15/4/9.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@property (weak,nonatomic) UIImageView *imageView;

@end

/*
 NSObject多线程方法
 
 1. [NSThread currentThread] 可以返回当前运行的线程
 num = 1 说明是主线程
 
 在任何多线程技术中(NSThread,NSOperation,GCD)，均可以使用此方法，查看当前的线程情况。
 
 2. 新建后台线程，调度任务
 [self performSelectorInBackground:@selector(bigTask) withObject:nil]
 
 使用performSelectorInBackground是可以修改UI的，but强烈不建议如此使用。
 
 3. 更新界面
 使用performSelectorOnMainThread可以在主线程上执行任务。
 
 提示：NSObject对象均可以调用此方法。
 
 4. 内存管理
 线程任务要包在@autoreleasepool（自动释放池）中，否则容易引起内存泄露，而且非常难发现。
 */



@implementation ViewController

#pragma mark 耗时操作
- (void) bigTask
{
    @autoreleasepool {
        for (NSInteger i = 0 ; i < 300 ; i++)
        {
            NSString *str = [NSString stringWithFormat:@"i = %li",(long)i];
            NSLog(@"%@",str);
        }
        
        NSLog(@"大任务 - %@",[NSThread currentThread]);
        
        UIImage *image = [UIImage imageNamed:@"头像2.png"];
        // 在主线程中修改self.imageView的image
        [self performSelectorOnMainThread:@selector(changedImage:)
                               withObject:image
                            waitUntilDone:YES];
    }
}

- (void) changedImage : (UIImage *) image
{
    NSLog(@"修改头像  %@",[NSThread currentThread]);
    
    [self.imageView setImage:image];
}

- (void) smallTask
{
    NSString *str = nil;
    for (NSInteger i = 0 ; i < 30000 ; i++)
    {
        str = [NSString stringWithFormat:@"i = %li",(long)i];
    }
    
    NSLog(@"%@",str);
    NSLog(@"小任务 - %@",[NSThread currentThread]);
}

#pragma mark - Actions
- (void) button1
{
    // 在后台调用耗时操作
    // performSelectorInBackground会新建一个后台线程，并在该线程中执行调用的方法
    [self performSelectorInBackground:@selector(bigTask) withObject:nil];
    
    NSLog(@"大任务按钮:    %@",[NSThread currentThread]);
}

- (void) button2
{
    NSLog(@"小任务按钮:    %@",[NSThread currentThread]);
    [self smallTask];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setFrame:CGRectMake(110, 100, 100, 40)];
    [button1 setTitle:@"大任务" forState:UIControlStateNormal];
    [button1 setEnabled:YES];
    
    [button1 addTarget:self action:@selector(button1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setFrame:CGRectMake(110, 200, 100, 40)];
    [button2 setTitle:@"小任务" forState:UIControlStateNormal];
    [button2 setEnabled:YES];
    
    [button2 addTarget:self action:@selector(button2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    NSLog(@"%@",[NSThread currentThread]);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 260, 100, 100)];
    UIImage *image = [UIImage imageNamed:@"头像1.png"];
    [imageView setImage:image];
    
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
