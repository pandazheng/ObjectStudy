//
//  Ticket.h
//  ThreadTicket
//
//  Created by panda zheng on 15/4/10.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ticket : NSObject

//实例化票据的单例
+ (Ticket *) sharedTicket;

// 在多线程应用中，所有被抢夺资源的属性需要设置为原子属性
// 系统会在多线程抢夺时，保证该属性有且仅有一个线程能够访问
// 注意：使用atomic属性，会降低系统性能，在开发多线程应用时，尽量不要资源
// 另外，atomic属性，必须与@synchronized（同步锁）一起使用

//票数
@property (assign,atomic) NSInteger tickets;

@end
