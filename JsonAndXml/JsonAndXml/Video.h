//
//  Video.h
//  JSON & XML
//
//  Created by apple on 13-10-10.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 异步加载网络图像的内存缓存解决方法
 
 1. 在对象中定义一个UIImage
 2. 在控制器中，填充表格内容时，判断UIImage是否存在内容
    1> 如果cacheImage不存在，显示占位图像，同时开启异步网络连接加载网络图像
        网络图像加载完成后，设置对象的cacheImage
        设置完成后，刷新表格对应的行
    2> 如果cacheImage存在，直接显示cacheImage
 */

@interface Video : NSObject

@property (assign, nonatomic) NSInteger videoId;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger length;
@property (strong, nonatomic) NSString *videoURL;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *teacher;

@property (strong, nonatomic) UIImage *cacheImage;
// 视频时长的字符串
@property (strong, nonatomic, readonly) NSString *lengthStr;

@end
