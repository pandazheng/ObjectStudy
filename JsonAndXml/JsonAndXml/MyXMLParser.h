//
//  MyXMLParser.h
//  JSON & XML
//
//  Created by apple on 13-10-10.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>

// 2. 交互的元素：elementName attributeDict
// 4. 交互的元素：elementName 中转的字符串
// 5. 完成仅通知即可
// 6. 出错仅通知即可

// 定义块代码
typedef void(^startElementBlock)(NSDictionary *dict);
typedef void(^endElementBlock)(NSString *elementName, NSString *result);
typedef void(^xmlParserNotificationBlock)();

@interface MyXMLParser : NSObject

// 定义解析方法
/*
 参数：
 data       XML数据
 startName  开始的节点名称
 startElement   开始节点方法
 endElement     结束节点方法
 finishedParser 文档解析结束
 errorParser    文档解析出错
 */
- (void)xmlParserWithData:(NSData *)data
                startName:(NSString *)startName
             startElement:(startElementBlock)startElement
               endElement:(endElementBlock)endElement
           finishedParser:(xmlParserNotificationBlock)finishedParser
              errorParser:(xmlParserNotificationBlock)errorParser;

@end
