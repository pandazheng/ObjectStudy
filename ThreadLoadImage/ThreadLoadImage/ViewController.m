//
//  ViewController.m
//  ThreadLoadImage
//
//  Created by panda zheng on 15/4/9.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"

/*
 1. NSThread
 1> 类方法 detachNewThreadSelector
 直接启动线程，调用选择器方法
 
 2> 成员方法 initWithTarget
 需要使用start方法，才能启动实例化出来的线程
 
 优点：简单
 缺点：
 * 控制线程的生命周期比较困难
 * 控制并发线程数
 * 先后顺序困难
 例如：下载图片(后台线程) -> 滤镜美化(后台线程) -> 更新UI(主线程)
 
 2. NSOperation
 1> NSInvocationOperation
 2> NSBlockOperation
 
 定义完Operation之后，将操作添加到NSOperationQueue即可启动线程，执行任务
 
 使用：
 1>  setMaxConcurrentOperationCount 可以控制同时并发的线程数量
 2>  addDependency 可以指定线程之间的依赖关系，从而达到控制线程执行顺序的目的
 
 提示：
 要更新UI，需要使用[NSOperationQueue mainQueue]addOperationWithBlock:
 在主操作队列中更新界面
 
 3. GCD
 1) 全局global队列
 方法：dispatch_get_global_queue（获取全局队列）
 优先级：DISPATCH_QUEUE_PRIORITY_DEFAULT
 所有任务是并发（异步）执行的
 
 2) 串行队列
 方法：dispatch_queue_create（创建串行队列，串行队列不能够获取）
 提示：队列名称可以随意，不过不要使用@
 
 3) 主队列
 主线程队列
 方法：dispatch_get_main_queue（获取主队列）
 
 在gcd中，同步还是异步取决于任务执行所在的队列，更方法名没有关系
 
 具体同步、异步与三个队列之间的关系，一定要反复测试，体会！
 */


@interface ViewController ()

//图像集合
@property (strong,nonatomic) NSSet *imageViewSet;

//定义操作队列
@property (strong,nonatomic) NSOperationQueue *queue;

@end

@implementation ViewController

#pragma mark 设置UI
- (void) setupUI
{
    //实例化图像视图集合
    NSMutableSet *imageSet = [NSMutableSet setWithCapacity:28];
    
    //一共17张图片，每行显示4张，一共显示7行
    NSInteger w = 640 / 8;
    NSInteger h = 400 / 8;
    for (NSInteger row = 0 ; row < 7 ; row++)
    {
        for (NSInteger col = 0 ; col < 4 ; col++)
        {
            //计算图片的位置
            NSInteger x = col * w;
            NSInteger y = row * h;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
            //顺度填充图象
            //NSInteger num = (row * 4 + col) % 17 + 1;
            //NSString *imageName = [NSString stringWithFormat:@"NatGeo%02ld.png",(long)num];
            //UIImage *image = [UIImage imageNamed:imageName];
            
            //[imageView setImage:image];
            [self.view addSubview:imageView];
            [imageSet addObject:imageView];
        }
    }
    
    self.imageViewSet = imageSet;
    
    //添加按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(110, 385, 100, 40)];
    [button setTitle:@"刷新图片" forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
    
    //实例化操作队列
    self.queue = [[NSOperationQueue alloc] init];
}

#pragma mark 按钮的监听方法
- (void) click
{
    NSLog(@"click me");
    //[self threadLoad];
    //[self operationLoad];
    //[self operationBlockLoad];
    //[self operationDemo];
    [self gcdLoad];
}

#pragma mark - NSThread加载图片方法
- (void) threadLoadImage : (UIImageView *) imageView
{
    //线程方法一定要加autoreleasepool
    @autoreleasepool {
        //设置imageView的内容
        NSLog(@"%@",[NSThread currentThread]);
    
        NSInteger num = arc4random_uniform(17) + 1;
        NSString *imageName = [NSString stringWithFormat:@"NatGeo%02ld.png",(long)num];
    
        UIImage *image = [UIImage imageNamed:imageName];
    
        //[imageView setImage:[UIImage imageNamed:imageName]];
    
        //在主线程上更新UI
        [imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
        /*[[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [imageView setImage:image];
        }];*/
    }
}

- (void) threadLoad
{
    for (UIImageView *imageView in self.imageViewSet)
    {
        //新建线程调用threadLoadImage方法
        //[NSThread detachNewThreadSelector:@selector(threadLoadImage:) toTarget:self withObject:imageView];
        
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoadImage:) object:imageView];
        //启动线程
        [thread start];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSOperation 方法

#pragma mark NSOperation操作之间的顺序
- (void)operationDemo
{
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载 %@", [NSThread currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"美化 %@", [NSThread currentThread]);
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"更新 %@", [NSThread currentThread]);
    }];
    // Dependency依赖
    // 提示：依赖关系可以多重依赖
    // 注意：不要建立循环依赖
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    
    [self.queue addOperation:op3];
    [self.queue addOperation:op1];
    [self.queue addOperation:op2];
}

#pragma mark - NSThread加载图片方法
- (void)operationLoadImage:(UIImageView *)imageView
{
    // 线程方法一定要加autoreleasepool
    @autoreleasepool {
        // 设置imageView的内容
        NSLog(@"%@", [NSThread currentThread]);
        
        //        [NSThread sleepForTimeInterval:1.0f];
        
        NSInteger num = arc4random_uniform(17) + 1;
        NSString *imageName = [NSString stringWithFormat:@"NatGeo%02ld.png", (long)num];
        
        UIImage *image = [UIImage imageNamed:imageName];
        
        // 在主线程队列上更新UI
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [imageView setImage:image];
        }];
    }
}

#pragma mark NSOperation加载图像
- (void)operationBlockLoad
{
    for (UIImageView *imageView in self.imageViewSet) {
        
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            [self operationLoadImage:imageView];
        }];
        
        [self.queue addOperation:op];
    }
}

-(void) operationLoad
{
    //队列可以设置同时并发线程的数量
    [self.queue setMaxConcurrentOperationCount:4];
    
    for (UIImageView *imageView in self.imageViewSet)
    {
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationLoadImage:) object:imageView];
        //如果直接调用operation的start方法，是在主线程队列上运行的，不会开启新的线程
        //[op start];
        // 将Invocation添加到队列，一添加到队列，就会开启新的线程执行任务
        [self.queue addOperation:op];
    }
}

#pragma mark GCD加载图像
- (void) gcdLoad
{
    /*
     1. 全局global队列
     方法：dispatch_get_global_queue（获取全局队列）
     优先级：DISPATCH_QUEUE_PRIORITY_DEFAULT
     所有任务是并发（异步）执行的
     
     2. 串行队列
     方法：dispatch_queue_create（创建串行队列，串行队列不能够获取）
     提示：队列名称可以随意，不过不要使用@
     
     3. 主队列
     主线程队列
     方法：dispatch_get_main_queue（获取主队列）
     
     在gcd中，同步还是异步取决于任务执行所在的队列，更方法名没有关系
     */
    // 派发dispatch_
    // 异步async不执行，并发执行
    // 优先级priority，使用默认优先级即可
    
    // 1. 在全局队列中调用异步任务
    // 1) 全局队列，全局调度队列是有系统负责的，开发时不用考虑并发线程数量问题
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 串行队列，需要创建，不能够get
    // DISPATCH_QUEUE_SERIAL串行队列
    //
    //    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
    // 主队列
    
    //获取全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for (UIImageView *imageView in self.imageViewSet)
    {
        //全局队列上异步调用方法，加载并更新图像
        dispatch_async(queue, ^{
            NSLog(@"GCD - %@",[NSThread currentThread]);
            
            NSInteger num = arc4random_uniform(17) + 1;
            NSString *imageName = [NSString stringWithFormat:@"NatGeo%02ld.png",(long)num];
            
            //通常此处的image是从网络上获取的
            UIImage *image = [UIImage imageNamed:imageName];
            
            //在主线程队列中，调用异步方法设置UI
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"更新图片 - %@",[NSThread currentThread]);
                [imageView setImage:image];
            });
        });
    }
}

#pragma mark GCD演示
- (void)gcdDemo
{
    /*
     1. 全局global队列
     方法：dispatch_get_global_queue（获取全局队列）
     优先级：DISPATCH_QUEUE_PRIORITY_DEFAULT
     所有任务是并发（异步）执行的
     
     2. 串行队列
     方法：dispatch_queue_create（创建串行队列，串行队列不能够获取）
     提示：队列名称可以随意，不过不要使用@
     
     3. 主队列
     主线程队列
     方法：dispatch_get_main_queue（获取主队列）
     
     在gcd中，同步还是异步取决于任务执行所在的队列，更方法名没有关系
     */
    // 派发dispatch_
    // 异步async不执行，并发执行
    // 优先级priority，使用默认优先级即可
    
    // 1. 在全局队列中调用异步任务
    // 1) 全局队列，全局调度队列是有系统负责的，开发时不用考虑并发线程数量问题
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 串行队列，需要创建，不能够get
    // DISPATCH_QUEUE_SERIAL串行队列
    //
    //    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
    // 主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 2) 在队列中执行异步任务
    dispatch_async(queue, ^{
        NSLog(@"任务1 %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务2 %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务3 %@", [NSThread currentThread]);
    });
    
}

@end
