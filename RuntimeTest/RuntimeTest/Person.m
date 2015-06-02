//
//  Person.m
//  RuntimeTest
//
//  Created by panda zheng on 15/4/18.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSString *) description
{
    return [NSString stringWithFormat:@"[age=%d,name=%@]",_age,_name];
}

@end
