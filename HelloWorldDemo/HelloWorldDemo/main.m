//
//  main.m
//  HelloWorldDemo
//
//  Created by panda zheng on 15/4/15.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelloWorld.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        HelloWorld *myObject = [[HelloWorld alloc] init];
        [myObject printGreeting];
    }
    return 0;
}
