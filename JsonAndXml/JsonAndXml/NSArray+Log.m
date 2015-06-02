//
//  NSArray+Log.m
//  JSON & XML
//
//  Created by apple on 13-10-10.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "NSArray+Log.h"

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendFormat:@"%lu (", (unsigned long)self.count];
    
    for (NSObject *obj in self) {
        [str appendFormat:@"\t%@\n,", obj];
    }
    
    [str appendString:@")"];
    
    return str;
}

@end
