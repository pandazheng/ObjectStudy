//
//  Ticket.m
//  ThreadTicket
//
//  Created by panda zheng on 15/4/10.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "Ticket.h"

/**
 实现单例模型需要做三件事情
 
 1. 使用全局静态变量记录住第一个被实例化的对象
 static Ticket *SharedInstance
 
 2. 重写allocWithZone方法，并使用dispatch_once_t，从而保证在多线程情况下，
 同样只能实例化一个对象副本
 
 3. 建立一个以shared开头的类方法实例化单例对象，便于其他类调用，同时不容易引起歧义
 同样用dispatch_once_t确保只有一个副本被建立
 
 
 关于被抢夺资源使用的注意事项
 
 在多线程应用中，所有被抢夺资源的属性需要设置为原子属性
 系统会在多线程抢夺时，保证该属性有且仅有一个线程能够访问
 
 注意：使用atomic属性，会降低系统性能，在开发多线程应用时，尽量不要资源
 另外，atomic属性，必须与@synchronized（同步锁）一起使用
 
 */


static Ticket *SharedInstance;

@implementation Ticket

//使用内存地址实例对象，所有实例化方法，最终都会调用此方法
//要实例化出来唯一的对象，需要一个变量记录住第一个实例化出来的对象
+ (id) allocWithZone:(struct _NSZone *)zone
{
    // 解决多线程中，同样只能实例化出一个对象副本
    /*if (SharedInstance == nil)
    {
        SharedInstance = [super allocWithZone:zone];
    }*/
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        SharedInstance = [super allocWithZone:zone];
    });
    
    return SharedInstance;
}

//建立一个单例对象，便于其他类使用
+ (Ticket *) sharedTicket
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        SharedInstance = [[Ticket alloc] init];
    });
    
    return SharedInstance;
}

@end
