//
//  MainViewController.m
//  JsonAndXml
//
//  Created by panda zheng on 15/4/12.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "MainViewController.h"
#import "Video.h"
#import "VideoCell.h"
#import "MyXMLParser.h"

static NSString *ID = @"MyCell";

#define kBaseURL @"http://192.168.3.252/~apple"

/*
 在开发网络应用中
 
 1. 数据是同步加载的，可以保证用户有的看
 2. 图像、音频、视频是异步加载的，保证在不阻塞主线程使用的前提下，用户能够渐渐地看到多媒体信息
 
 零. 关于图像内存缓存的异步加载
 
 1. 在对象中定义一个UIImage
 2. 在控制器中，填充表格内容时，判断UIImage是否存在内容
 1> 如果cacheImage不存在，显示占位图像，同时开启异步网络连接加载网络图像
 网络图像加载完成后，设置对象的cacheImage
 设置完成后，刷新表格对应的行
 2> 如果cacheImage存在，直接显示cacheImage
 
 一. JSON解析
 [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
 
 提示：反序列化JSON数据后，可以将数据保存至plist文件，便于开发调试！
 
 
 二. XML文件解析步骤
 使用前，需要做的步骤
 
 1) 实例化解析器
 2) 设置代理
 3) 解析器解析
 
 解析步骤
 
 1） 解析文档
 在整个XML文件解析完成之前，2、3、4方法会不断被循环调用
 2） 开始解析一个元素
 3 接收元素的数据（因为元素内容过大，此方法可能会被重复调用，需要拼接数据）
 4）结束解析一个元素
 5) 解析文档结束
 6) 解析出错
 
 三. XML解析的思路
 
 目前的资源：dataList记录表格中显示的数组，保存video对象。
 
 0. 数据初始化的工作，实例化dataList和第3步需要使用的全局字符串
 
 1. 如果在第2个方法中，elementName == video，会在attributeDict中包含videoId
 2. 如果在第2个方法中，elementName == video，需要实例化一个全局的video属性，
 记录2、3、4步骤中解析的当前视频信息对象
 3. 其他得属性会依次执行2、3、4方法，同时第3个方法有可能会被多次调用
 4. 在第3个方法中，需要拼接字符串——需要定义一个全局的属性记录中间的过程
 5. 在第4个方法中，可以通过第3个方法拼接的字符串获得elementName对应的内容
 可以设置全局video对象的elementName对应的数值
 6. 在第4个方法中，如果elementName == video，则将该对象插入self.dataList
 
 需要的准备工作
 1) 全局的字符串，记录每一个元素的完整内容
 2) 全局的video对象，记录当前正在解析的元素
 
 四. 要使用块代码的方式对XML解析进行包装，实际上是将所有的解析工作包装到另外一个类中，
 而在实际开发中，简化XML解析的工作。
 
 开发思路
 1) 对六个解析方法依次分析，判断哪些方法需要和外部对象交互，以及交互的参数
 2) 根据分析，定义块代码类型
 3) 定义解析方法，接收所有块代码以及解析数据
 4）调整代码，将数据与处理分离
 
 提示：真正的数据处理，实际上还是在ViewController中完成的，只是通过块代码的方式
 将原有离散的处理方法，统一到了一个方法中。
 */

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak,nonatomic) UITableView *tableView;

//全局的数据数组
@property (strong,nonatomic) NSMutableArray *dataList;

// 2) 全局的video对象，记录当前正在解析的元素
@property (strong, nonatomic) Video *currentVideo;

@end

@implementation MainViewController

#pragma mark 实例化视图
- (void) loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    // 1. tableView
    CGRect frame = self.view.bounds;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 44) style:UITableViewStylePlain];
    
    // 1) 数据源
    [tableView setDataSource:self];
    // 2) 代理
    [tableView setDelegate:self];
    // 3) 设置表格高度
    [tableView setRowHeight:80];
    // 4) 设置分隔线
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 2. toolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, tableView.bounds.size.height, 375, 44)];
    toolBar.barStyle = UIBarStyleDefault;
    [self.view addSubview:toolBar];
    
    // 添加toolBar按钮
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"load json" style:UIBarButtonItemStyleDone target:self action:@selector(loadJson)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"load json" style:UIBarButtonItemStyleDone target:self action:@selector(loadXML)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:@[item3,item1,item3,item2,item3]];
}

#pragma mark - UITableView数据源方法
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
//    }
    
    // 1. 使用可重用标示符查询可重用单元格
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 设置单元格内容
    Video *v = self.dataList[indexPath.row];
    
    cell.textLabel.text = v.name;
    cell.detailTextLabel.text = v.teacher;
    cell.lengthLabel.text = v.lengthStr;
    
    // 加载图片
    
    // 1) 同步加载网络图片
    // 注意：在开发网络应用时，不要使用同步方法加载图片，否则会严重影响用户体验
    // 同步方法，意味着，这一指令执行完成之前，后续的指令都无法执行
    //    NSString *imagePath = [NSString stringWithFormat:@"%@%@", kBaseURL, v.imageURL];
    //    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    //    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    //    UIImage *image = [UIImage imageWithData:imageData];
    
    // 2) 异步加载网络图片
    // gcd、nsoperation、nsthread
    // 网络连接本身就有异步命令 sendAsync
    
    // 如果缓存图像不存在
    if (v.cacheImage == nil) {
        // 使用默认图像占位，既能够保证有图像，又能够保证有地方！
        UIImage *image = [UIImage imageNamed:@"user_default.png"];
        [cell.imageView setImage:image];
        
        // 开启异步连接，加载图像，因为加载完成之后，需要刷新对应的表格行
        [self loadImageAsyncWithIndexPath:indexPath];
    } else {
        [cell.imageView setImage:v.cacheImage];
    }
    
    return cell;
}

//- (void) loadView
//{
//    NSLog(@"loadView......");
//    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
//    
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 200, 200)];
//    button.backgroundColor = [UIColor redColor];
//    [self.view addSubview:button];
//    NSLog(@"load button......");
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%f,%f",[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    // Do any additional setup after loading the view.
//    NSLog(@"viewDidLoad......");
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    label.text = @"text";
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:label];
//    NSLog(@"load label......");
    
    // 注册可重用单元格
    [self.tableView registerClass:[VideoCell class] forCellReuseIdentifier:ID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark 异步加载网络图片
// 由于UITableViewCell是可重用的，为了避免用户频繁快速刷新表格，造成数据冲突，
// 不能直接将UIImageView传入异步方法
// 正确地解决方法是：将表格行的indexPath传入异步方法，加载完成图像后，直接刷新指定的行
- (void)loadImageAsyncWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"=====indexpath %ld", (long)indexPath.row);
    
    Video *v = self.dataList[indexPath.row];
    
    // 1. url
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", kBaseURL, v.imageURL];
    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    
    // 2. request
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    
    // 3. connection sendasync
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // 将网络数据保存至Video的缓存图像
        v.cacheImage = [UIImage imageWithData:data];
        
        // 刷新表格
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }];
}

#pragma mark - ACTIONs

#pragma mark 处理JSON数据
- (void)handlerJSONData:(NSData *)data
{
    // JSON文件中的[]表示是一个数组
    // 反序列化JSON数据
    /*
     序列化：    将NSObject转换成序列数据，以便可以通过互联网进行传输
     反序列化：  将网络上获取的数据，反向生成我们需要的对象
     */
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    // 提示：如果开发网络应用，可以将反序列化出来的对象，保存至沙箱，以便后续开发使用
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [docs[0]stringByAppendingPathComponent:@"json.plist"];
    [array writeToFile:path atomically:YES];
    
    // 给数据列表赋值
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        Video *video = [[Video alloc]init];
        
        // 给video赋值
        [video setValuesForKeysWithDictionary:dict];
        
        [arrayM addObject:video];
    }
    
    self.dataList = arrayM;
    
    // 刷新表格
    [self.tableView reloadData];
    
    NSLog(@"%@", arrayM);
}

#pragma mark - 加载JSON
- (void) loadJson
{
    NSLog(@"load json");
    // 从web服务器直接加载数据
    NSString *str = @"http://192.168.3.252/~apple/itcast/videos.php?format=json";

    // 提示：NSData本身具有同步方法，但是在实际开发中，不要使用此方法
    // 在使用NSData的同步方法时，无法指定超时时间，如果服务器连接不正常，会影响用户体验
    // NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
    
    // 1. 建立NSURL
    NSURL *url = [NSURL URLWithString:str];
    // 2. 建立NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
    
    // 3. 利用NSURLConnection的同步方法加载数据
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //不要忘记错误处理
    if (data != nil)
    {
        // 仅用于跟踪调试使用
        // NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        // 做JSON数据的处理
        // 提示：在处理网络数据时，不需要将NSData转换成NSString
        [self handlerJSONData:data];
    }
    else if (data == nil && error == nil)
    {
        NSLog(@"空数据");
    }
    else
    {
        NSLog(@"%@",error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络超时" delegate:nil
    cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - 加载XML
- (void) loadXML
{
    // 0. 获取网络数据
    // 从web服务器直接加载数据
    NSString *str = @"http://192.168.3.252/~apple/itcast/videos.php?format=xml";
    
    // 1) 建立NSURL
    NSURL *url = [NSURL URLWithString:str];
    // 2) 建立NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
    
    // 3) 利用NSURLConnection的同步方法加载数据
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    MyXMLParser *myParser = [[MyXMLParser alloc]init];
    
    // 懒加载实例化数据
    if (self.dataList == nil) {
        self.dataList = [NSMutableArray array];
    } else {
        [self.dataList removeAllObjects];
    }
    
    // 解析数据
    [myParser xmlParserWithData:data startName:@"video" startElement:^(NSDictionary *dict) {
        
        // 1. 实例化currentVideo
        self.currentVideo = [[Video alloc]init];
        
        // 2. 设置videoId
        self.currentVideo.videoId = [dict[@"videoId"]integerValue];
    } endElement:^(NSString *elementName, NSString *result) {
        
        if ([elementName isEqualToString:@"name"]) {
            self.currentVideo.name = result;
        } else if ([elementName isEqualToString:@"length"]) {
            self.currentVideo.length = [result integerValue];
        } else if ([elementName isEqualToString:@"videoURL"]) {
            self.currentVideo.videoURL = result;
        } else if ([elementName isEqualToString:@"imageURL"]) {
            self.currentVideo.imageURL = result;
        } else if ([elementName isEqualToString:@"desc"]) {
            self.currentVideo.desc = result;
        } else if ([elementName isEqualToString:@"teacher"]) {
            self.currentVideo.teacher = result;
        } else if ([elementName isEqualToString:@"video"]) {
            [self.dataList addObject:self.currentVideo];
        }
    } finishedParser:^{
        self.currentVideo = nil;
        
        [self.tableView reloadData];
    } errorParser:^{
        NSLog(@"解析出现错误!");
        
        // 清空临时数据
        self.currentVideo = nil;
        
        // 清空数组
        [self.dataList removeAllObjects];
    }];
}

@end
