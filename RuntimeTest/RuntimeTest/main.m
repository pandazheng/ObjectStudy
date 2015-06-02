//
//  main.m
//  RuntimeTest
//
//  Created by panda zheng on 15/4/18.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import <objc/message.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *p = [[Person alloc] init];
        
        [p setAge:20];
        [p setName:@"jack"];
        NSLog(@"%@",p);
    }
    return 0;
}
