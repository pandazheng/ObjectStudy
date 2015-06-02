//
//  main.m
//  RuntimeDemo
//
//  Created by panda zheng on 15/4/14.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

//#import <Foundation/Foundation.h>

//int main(int argc, const char * argv[]) {
//    @autoreleasepool {
//        // insert code here...
//        NSLog(@"Hello, World!");
//    }
//    return 0;
//}

/*
下面的代码用OC的语法形式写出来就是：
@interface NSPower : NSObject

-(void) fun;

@end

NSPower* powerObj = [NSPower alloc];
[powerObj fun];*/


#include <stdio.h>
#include <objc/runtime.h>
#include <objc/message.h>

void power_fun(id self,SEL cmd)
{
    printf("hello world");
}

int main(int argc,const char* argv[])
{
    //新创建一个Class对象，继承于NSObject,名字叫NSPower(用于注册一个Class,Class的名字叫NSPower)
    Class powerCls = objc_allocateClassPair(objc_getClass("NSObject"), "NSPower", 0);
    //定义一个SEL,也就是OC里面的Selector,我理解为一个方法的Key,通过这个名字可以找到一个对应的方法实现函数
    SEL selFun = sel_registerName("fun");
    
    //为这个Class添加一个方法，名字叫fun,实现为power_fun(之前声明的一个C函数)
    //后面这个字符串是干嘛的呢？用来说明参数的，OC语言特别为每种参数类型指定了一个编码
    //比如V@:的意思是，返回值是void,第一个参数是id,第二个参数是SEL
    class_addMethod(powerCls, selFun, (IMP)power_fun, "V@:");
    
    //注册这个Class,从此以后，你就可以使用NSPower这个名字来创建一个类的实例了
    objc_registerClassPair(powerCls);
    
    //以下代码就是创建一个NSPower的实例，并且调用fun方法
    //得到一个class的实例
    Class cls = objc_getClass("NSPower");
    //对这个class发送alloc消息，创建一个class对象
    id obj = objc_msgSend((id)cls,sel_registerName("alloc"));
    //对这个对象发送一个fun消息，这样会调用到之前的power_fun方法
    objc_msgSend(obj,selFun);
    
    return 0;
}

